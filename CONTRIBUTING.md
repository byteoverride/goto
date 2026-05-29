# Contributing to goto

Thanks for your interest in contributing to goto!

## Development Setup

```sh
git clone https://github.com/byteoverride/goto.git
cd goto
```

No build step needed — goto is a pure shell script.

## Running Tests

```sh
./verify.sh
```

Tests output TAP format and run in an isolated temporary home directory.

## Linting

```sh
shellcheck goto goto.sh install.sh verify.sh completions/goto.bash
```

All scripts must pass shellcheck with zero warnings before merge.

## Code Style

- The main `goto` script must be **POSIX sh** compatible — no bashisms
- Use `printf` instead of `echo` for output (POSIX portable)
- Move all variables out of printf format strings — use `%s` placeholders
- Keep `shellcheck disable` directives to a minimum and only for justified cases (color codes in format strings)
- Shortcut names are validated with `validate_name()` — only `[a-zA-Z0-9_-]` allowed
- Error messages go to stderr
- Exit code 1 for operational errors, exit code 2 for usage errors

## Adding a New Flag

When adding a new command-line flag, update all of these:

1. `goto` — add the case and function
2. `goto.sh` — no change needed (all `-*` flags are forwarded automatically)
3. `goto.1` — add to the OPTIONS section of the man page
4. `verify.sh` — add test cases
5. `completions/goto.fish` — add Fish completion entry
6. `CHANGELOG.md` — document the addition
7. `README.md` — update usage section if user-facing

## File Structure

```
goto                    Main executable (POSIX sh)
goto.sh                 Shell integration for Bash/Zsh (sourced, not executed)
goto.1                  Man page (troff format)
install.sh              User-local installer
verify.sh               Test suite
Makefile                System-wide install/uninstall
completions/
  goto.bash             Bash completion (for system-wide install)
  _goto                 Zsh completion (for system-wide install)
  goto.fish             Fish shell integration and completion
debian/                 Debian packaging
packaging/              Arch PKGBUILD
```

## Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-change`)
3. Make your changes
4. Run `shellcheck` and `./verify.sh` — both must pass
5. Update documentation (man page, README, CHANGELOG)
6. Submit a pull request

## Reporting Issues

Please include:
- Your shell and version (`bash --version`, `zsh --version`, etc.)
- Your OS and version
- Steps to reproduce the issue
- Expected vs actual behavior
