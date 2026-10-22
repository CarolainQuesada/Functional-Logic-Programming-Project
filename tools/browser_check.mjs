// Real Chrome rendering and layout checks using Node's built-in CDP transport.
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

const source = resolve(process.argv[2] ?? 'output/index.html');
const destination = resolve(process.argv[3] ?? 'output/browser-checks');
const browser = [process.env.CHROME_BIN,
  'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
  '/usr/bin/google-chrome', '/usr/bin/chromium'].find(path => path && existsSync(path));
assert(browser, 'Chrome is required; set CHROME_BIN to its executable.');
assert(existsSync(source), 'Generate the HTML before running browser checks.');
mkdirSync(destination, { recursive: true });
const profile = mkdtempSync(join(tmpdir(), 'knowledge-chrome-'));
const child = spawn(browser, ['--headless=new', '--disable-gpu', '--no-first-run',
  '--no-default-browser-check', '--remote-debugging-port=0', `--user-data-dir=${profile}`, 'about:blank'],
{ windowsHide: true, stdio: ['ignore', 'ignore', 'pipe'] });
let socket;
try {
  const endpoint = await new Promise((fulfill, reject) => {
    let logs = '';
    const deadline = setTimeout(() => reject(new Error('Chrome startup timed out.')), 20000);
    child.on('error', reject);
    child.stderr.on('data', chunk => {
      logs += chunk;
      const match = /DevTools listening on (ws:\/\/[^\s]+)/.exec(logs);
      if (match) { clearTimeout(deadline); fulfill(match[1]); }
    });
  });
  socket = new WebSocket(endpoint);
  await new Promise((fulfill, reject) => {
    socket.addEventListener('open', fulfill, { once: true });
    socket.addEventListener('error', reject, { once: true });
  });
  let sequence = 0;
  const pending = new Map();
  const exceptions = [];
  socket.addEventListener('message', event => {
    const message = JSON.parse(event.data);
    if (message.method === 'Runtime.exceptionThrown') exceptions.push(message.params);
    if (message.id && pending.has(message.id)) {
      const { fulfill, reject, deadline } = pending.get(message.id);
      clearTimeout(deadline); pending.delete(message.id);
      if (message.error) reject(new Error(JSON.stringify(message.error)));
      else fulfill(message.result);
    }
  });
  const command = (method, params = {}, sessionId) => new Promise((fulfill, reject) => {
    const id = ++sequence;
    const deadline = setTimeout(() => { pending.delete(id); reject(new Error(`CDP timeout: ${method}`)); }, 15000);
    pending.set(id, { fulfill, reject, deadline });
    socket.send(JSON.stringify({ id, method, params, sessionId }));
  });
  const { targetId } = await command('Target.createTarget', { url: 'about:blank' });
  const { sessionId } = await command('Target.attachToTarget', { targetId, flatten: true });
  const tab = (method, params = {}) => command(method, params, sessionId);
  const evaluate = async expression => {
    const result = await tab('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
    assert(!result.exceptionDetails, JSON.stringify(result.exceptionDetails));
    return result.result.value;
  };
  await tab('Page.enable');
  await tab('Runtime.enable');
  await tab('Emulation.setEmulatedMedia', { features: [{ name: 'prefers-reduced-motion', value: 'reduce' }] });
  const evidence = [];
  for (const [label, width, height, mobile] of [['desktop', 1440, 1200, false], ['mobile', 390, 1100, true]]) {
    await tab('Emulation.setDeviceMetricsOverride', { width, height, mobile, deviceScaleFactor: 1 });
    await tab('Page.navigate', { url: pathToFileURL(source).href });
    let ready = false;
    for (let attempt = 0; attempt < 50; attempt++) {
      if (await evaluate('document.readyState === "complete" && !!document.querySelector("#validation")')) { ready = true; break; }
      await new Promise(fulfill => setTimeout(fulfill, 100));
    }
    assert(ready, 'Generated page did not load.');
    const layout = await evaluate(`({width:innerWidth, scrollWidth:document.documentElement.scrollWidth,
      sections:[...document.querySelectorAll('main section')].map(node=>node.id),
      links:[...document.querySelectorAll('a[href]')].map(node=>node.getAttribute('href')),
      scripts:document.scripts.length, title:document.title})`);
    assert.equal(layout.width, width, 'Chrome must emulate the requested viewport exactly.');
    assert(layout.scrollWidth <= width, `Page overflows: ${layout.scrollWidth} > ${width}`);
    for (const section of ['entities', 'relations', 'rules', 'knowledge', 'queries', 'validation']) {
      assert(layout.sections.includes(section), `Missing section: ${section}`);
    }
    for (const href of layout.links) {
      if (href.startsWith('#')) assert(await evaluate(`!!document.getElementById(${JSON.stringify(href.slice(1))})`));
      else assert(existsSync(join(dirname(source), href)), `Missing artifact: ${href}`);
    }
    assert.equal(layout.scripts, 0);
    await evaluate(`new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)))`);
    const screenshot = await tab('Page.captureScreenshot', { format: 'png', captureBeyondViewport: true,
      clip: { x: 0, y: 0, width, height, scale: 1 } });
    writeFileSync(join(destination, `${label}.png`), Buffer.from(screenshot.data, 'base64'));
    const metrics = await tab('Page.getLayoutMetrics');
    const full = await tab('Page.captureScreenshot', { format: 'png', captureBeyondViewport: true,
      clip: { x: 0, y: 0, width, height: metrics.cssContentSize.height, scale: 1 } });
    writeFileSync(join(destination, `${label}-full.png`), Buffer.from(full.data, 'base64'));
    writeFileSync(join(destination, `${label}-dom.html`), await evaluate('document.documentElement.outerHTML'));
    assert(await evaluate(`document.querySelector('.skip').focus(); document.activeElement.className === 'skip'`));
    await evaluate(`document.querySelector('nav a[href="#queries"]').click()`);
    assert(await evaluate(`location.hash === '#queries'`));
    evidence.push({ viewport: label, width, height, scrollWidth: layout.scrollWidth,
      sections: layout.sections, links_checked: layout.links.length, keyboard_focus: true,
      anchor_navigation: true, screenshot: `${label}.png` });
  }
  assert.equal(exceptions.length, 0, 'Browser runtime exceptions occurred.');
  const version = await command('Browser.getVersion');
  writeFileSync(join(destination, 'results.json'), JSON.stringify({ source, browser: version.product, checks: evidence }, null, 2));
  console.log('Desktop and mobile Chrome checks passed: exact viewports, no page overflow, working links and keyboard focus.');
  await command('Target.closeTarget', { targetId });
} finally {
  if (socket) socket.close();
  child.kill();
}
