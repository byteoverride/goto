# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-05-29

### Added
- Subpath navigation: `goto project/src/lib`
- Register current directory without specifying path: `goto -r name`
- Cleanup command to remove broken shortcuts: `goto -c` / `goto --cleanup`
- Rename shortcuts: `goto -R old new`
- Import/export shortcuts: `goto --export`, `goto --import <file>`
- Fish shell support with completions
- Tab completion for subpaths in Bash and Zsh
- `--version` / `-V` flag
- `--list` long flag alias for `-l`
- Man page (`goto.1`)
- Makefile with install/uninstall/lint/test targets
- Debian packaging (`debian/` directory)
- Arch Linux PKGBUILD (`packaging/PKGBUILD`)
- Comprehensive test suite with 36 TAP-compatible tests
- GitHub Actions CI (shellcheck + multi-shell testing)
- CONTRIBUTING.md with development guidelines
- Separate completion files for system-wide installation

### Fixed
- Error messages swallowed in shell wrapper (stderr was discarded)
- Shell wrapper only forwarded whitelisted flags (broke `--help`, `--version`)
- printf format string injection (variables in format strings)
- Trailing-newline bug (last config entry dropped if file lacked newline)
- realpath fallback allowed registering nonexistent paths
- `install.sh` used `echo -e` (not POSIX, breaks on dash)

### Changed
- Configuration path now respects `XDG_CONFIG_HOME` environment variable
- Exit code 2 for usage errors (was 1), following coreutils convention
- Colored output for missing paths in `goto -l`

## [0.1.0] - 2025-02-04

### Added
- Initial release
- Register, delete, list, and resolve directory shortcuts
- Bash and Zsh tab completion
- TTY-aware colored output with emoji indicators
- Automatic relative-to-absolute path resolution
- User-local installer (`install.sh`)
