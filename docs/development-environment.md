# Development environment

## Windows setup

Install GHC, GHCi, and Cabal with the official [GHCup installer](https://www.haskell.org/ghcup/). On Windows, GHCup uses an MSYS2 installation such as `C:\msys64`. Stack and Haskell Language Server are not required.

Install SWI-Prolog from its official distribution. Its default Windows location is `C:\Program Files\swipl`. Doxygen can be installed with the `DimitriVanHeesch.Doxygen` package from winget:

```powershell
winget install --id DimitriVanHeesch.Doxygen --exact --source winget
```

Add the executable directories for GHCup, SWI-Prolog, and Doxygen to the Windows `PATH`. Restart open terminals and editors after installation so they use the updated environment.

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

Chrome or Edge is used to open the generated HTML interface and the Doxygen documentation.

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

The temporary Haskell check was created outside the repository.
