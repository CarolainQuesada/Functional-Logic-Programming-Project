# Development environment

## Windows setup

Use the official [GHCup installer](https://www.haskell.org/ghcup/) for GHC, GHCi, and Cabal. This workstation reuses its existing MSYS2 installation at `C:\msys64`. Stack and Haskell Language Server are not required for the initial stage.

SWI-Prolog was already installed at `C:\Program Files\swipl`. Doxygen was installed using the `DimitriVanHeesch.Doxygen` package from winget:

```powershell
winget install --id DimitriVanHeesch.Doxygen --exact --source winget
```

The user PATH includes the executable directories for GHCup, SWI-Prolog, and Doxygen. Restart existing terminals and editors after installation so they inherit the updated environment.

## Verification commands

```powershell
git --version
ghc --version
ghci --version
cabal --version
swipl --version
doxygen --version
ghci -ignore-dot-ghci -v0 -e "sum [1..5 :: Integer]"
swipl -q -g 'X is 2+2, X =:= 4, writeln(prolog_check_passed)' -t halt
```

The GHCi expression should print `15`. The Prolog query should print `prolog_check_passed` and exit successfully. These checks validate the tools, not project functionality.

Chrome and Edge are installed for later HTML validation. No web interface is implemented in stage 1.

## Verified results

Checked on October 21, 2026:

| Tool | Version |
| --- | --- |
| Git | 2.44.0.windows.1 |
| GHC and GHCi | 9.10.3 |
| Cabal | 3.16.1.0 |
| SWI-Prolog | 10.1.17 |
| Doxygen | 1.18.0 |

- GHCi evaluated `sum [1..5 :: Integer]` and printed `15`.
- GHC compiled a temporary `Main.hs` with `-Wall -Werror`; the resulting executable printed `15` and exited successfully.
- SWI-Prolog evaluated and checked `2+2`, printed `prolog_check_passed`, and exited successfully.
- Git and Doxygen version commands completed successfully.

The temporary Haskell check was created outside the repository; no application code was added. An early GHCi check during installation failed to load a dependency in the restricted execution environment. The completed installation passed verification with access to its installed libraries.
