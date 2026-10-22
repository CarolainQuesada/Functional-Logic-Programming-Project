module HtmlStyle (stylesheet) where

stylesheet :: String
stylesheet = unlines
  [ ":root{color-scheme:light;--ink:#182b3b;--muted:#5d7080;--line:#dce5eb;--accent:#116b60;--paper:#f3f6f8}"
  , "*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;background:var(--paper);color:var(--ink);font:15px/1.6 'Segoe UI',Arial,sans-serif}"
  , "a{color:var(--accent)}a:focus-visible,summary:focus-visible{outline:3px solid #d89d22;outline-offset:4px}.skip{position:absolute;left:-9999px}.skip:focus{left:16px;top:16px;background:white;padding:12px;z-index:2}"
  , "header{background:#142f3d;color:#fff;padding:24px max(24px,calc((100% - 1160px)/2))}header .brand{font-size:14px;font-weight:700;letter-spacing:.12em}header span{color:#91c9bd}"
  , "nav{display:flex;gap:24px;flex-wrap:wrap;margin-top:16px}nav a{color:#d7e7ed;text-decoration:none;font-size:13px}nav a:hover{text-decoration:underline}"
  , "main{max-width:1208px;margin:auto;padding:40px 24px 64px}.eyebrow{text-transform:uppercase;letter-spacing:.14em;font-size:11px;font-weight:700;color:var(--accent)}"
  , "h1{font-size:clamp(30px,5vw,44px);line-height:1.15;letter-spacing:-.035em;margin:10px 0 16px}h2{font-size:21px;letter-spacing:-.02em;margin:0 0 6px}h3{font-size:15px;margin:0}p{margin:8px 0 16px}.muted{color:var(--muted)}"
  , ".hero{display:flex;align-items:flex-start;justify-content:space-between;gap:24px;margin-bottom:28px}.hero p{max-width:650px}.status{display:inline-block;border-radius:30px;padding:7px 14px;font-weight:700;font-size:12px;white-space:nowrap;background:#dcefe6;color:#175d44}.status.invalid{background:#fce4e4;color:#9b2929}.status.warning{background:#fff0c9;color:#755300}"
  , ".stats{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:24px}.stat,.panel{background:white;border:1px solid var(--line);border-radius:12px}.stat{padding:20px 24px}.stat strong{display:block;font-size:32px;line-height:1.2;margin-bottom:8px}.stat span{color:var(--muted);font-size:12px;text-transform:uppercase;letter-spacing:.08em}"
  , ".grid{display:grid;grid-template-columns:1fr 1fr;gap:24px}.panel{padding:24px;margin-bottom:24px;min-width:0;scroll-margin-top:20px}.grid .panel{margin-bottom:0}.section-note{font-size:13px;color:var(--muted);margin-bottom:20px}"
  , ".table-wrap{overflow-x:auto}table{width:100%;border-collapse:collapse;font-size:13px;text-align:left}caption{text-align:left;color:var(--muted);padding-bottom:12px}th{color:var(--muted);font-size:11px;text-transform:uppercase;letter-spacing:.06em}th,td{padding:12px 10px;border-bottom:1px solid var(--line);vertical-align:top}td:first-child{font-weight:600}tbody tr:last-child td{border-bottom:0}.tag{background:#edf4f5;color:#31616b;border-radius:5px;padding:3px 7px;font-size:11px}"
  , ".code{background:#112a38;color:#d9eee9;border-radius:8px;padding:20px;overflow:auto;font:12px/1.8 Consolas,'Courier New',monospace;white-space:pre;tab-size:4}details{margin:16px 0}summary{cursor:pointer;font-weight:600}.notice{padding:16px 18px;background:#eef7f3;border-left:3px solid var(--accent);border-radius:4px}.notice.error{background:#fff0f0;border-color:#b23c3c}"
  , ".diagnostic{padding:16px 0;border-bottom:1px solid var(--line)}.diagnostic:last-child{border:0}.diagnostic code{white-space:pre-wrap;overflow-wrap:anywhere;font-size:12px}.diagnostic p{margin:8px 0}.links{display:flex;gap:12px;flex-wrap:wrap;margin:20px 0}.links a{background:white;border:1px solid var(--line);border-radius:6px;padding:8px 14px;text-decoration:none;font-size:12px;font-weight:600}"
  , "footer{border-top:1px solid var(--line);padding-top:24px;margin-top:32px;color:var(--muted);font-size:12px}.wide{margin-top:24px}"
  , "@media(max-width:760px){main{padding:28px 16px}.hero{display:block}.hero .status{margin-top:4px}.stats{grid-template-columns:repeat(2,1fr);gap:10px}.stat{padding:16px}.grid{grid-template-columns:1fr;gap:16px}.panel{padding:18px}header{padding:20px 16px}nav{gap:16px}.code{padding:14px}}"
  , "@media(prefers-reduced-motion:reduce){html{scroll-behavior:auto}}"
  ]
