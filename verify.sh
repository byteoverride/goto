#!/bin/sh
# goto - Test suite (TAP-compatible output)
# Run: ./verify.sh

# Force POSIX sh emulation if running under zsh
# shellcheck disable=SC2292
[ -n "$ZSH_VERSION" ] && emulate sh

# No set -e — tests handle errors individually, and set -e behaves
# inconsistently across shells (zsh EXIT traps lose PATH).

# ── Test framework ──────────────────────────────────────────────

tests_run=0
tests_passed=0
tests_failed=0

pass() {
    tests_run=$((tests_run + 1))
    tests_passed=$((tests_passed + 1))
    printf "ok %d - %s\n" "$tests_run" "$1"
}

fail() {
    tests_run=$((tests_run + 1))
    tests_failed=$((tests_failed + 1))
    printf "not ok %d - %s\n" "$tests_run" "$1"
    if [ -n "$2" ]; then
        printf "#   expected: %s\n" "$2"
    fi
    if [ -n "$3" ]; then
        printf "#   got:      %s\n" "$3"
    fi
}

assert_eq() {
    if [ "$1" = "$2" ]; then
        pass "$3"
    else
        fail "$3" "$1" "$2"
    fi
}

assert_contains() {
    if printf '%s' "$2" | grep -q "$1"; then
        pass "$3"
    else
        fail "$3" "output containing '$1'" "$2"
    fi
}

# ── Setup ───────────────────────────────────────────────────────
# Isolate via XDG_CONFIG_HOME only — do NOT change HOME.
# Changing HOME breaks zsh on CI (it re-reads startup files and loses PATH).

TEST_HOME="/tmp/goto_test_$$"
rm -rf "$TEST_HOME"
mkdir -p "$TEST_HOME"
# Resolve symlinks (macOS: /tmp -> /private/tmp) so assertions match realpath output
TEST_HOME=$(cd "$TEST_HOME" && pwd -P)
export XDG_CONFIG_HOME="$TEST_HOME/.config"

GOTO_BIN="$(cd "$(dirname "$0")" && pwd)/goto"
CONFIG="$XDG_CONFIG_HOME/goto/config"

# shellcheck disable=SC2317
cleanup() {
    rm -rf "$TEST_HOME"
    unset XDG_CONFIG_HOME
}
trap cleanup EXIT

printf "# goto test suite\n"
printf "# Using test home: %s\n" "$TEST_HOME"
printf "# Binary: %s\n\n" "$GOTO_BIN"

# ── Test directories ────────────────────────────────────────────

TEST_DIR_1="$TEST_HOME/test_dir_1"
TEST_DIR_2="$TEST_HOME/test_dir_2"
TEST_DIR_SPACES="$TEST_HOME/test dir with spaces"
TEST_DIR_SUB="$TEST_HOME/test_project/src/lib"
mkdir -p "$TEST_DIR_1" "$TEST_DIR_2" "$TEST_DIR_SPACES" "$TEST_DIR_SUB"

# ════════════════════════════════════════════════════════════════
# REGISTRATION TESTS
# ════════════════════════════════════════════════════════════════

# 1. Register with absolute path
$GOTO_BIN -r abs_test "$TEST_DIR_1" >/dev/null 2>&1
if grep -q "^abs_test|${TEST_DIR_1}$" "$CONFIG"; then
    pass "Register with absolute path"
else
    fail "Register with absolute path"
fi

# 2. Register with relative path (.)
old_pwd=$(pwd)
cd "$TEST_DIR_2" || exit 1
$GOTO_BIN -r rel_test . >/dev/null 2>&1
cd "$old_pwd" || exit 1
if grep -q "^rel_test|${TEST_DIR_2}$" "$CONFIG"; then
    pass "Register with relative path (.)"
else
    fail "Register with relative path (.)"
fi

# 3. Register current directory (no path argument)
cd "$TEST_DIR_1" || exit 1
$GOTO_BIN -r curdir_test >/dev/null 2>&1
cd "$old_pwd" || exit 1
if grep -q "^curdir_test|${TEST_DIR_1}$" "$CONFIG"; then
    pass "Register current dir (no path argument)"
else
    fail "Register current dir (no path argument)"
fi

# 4. Register overwrites existing shortcut
$GOTO_BIN -r abs_test "$TEST_DIR_2" >/dev/null 2>&1
count=$(grep -c "^abs_test|" "$CONFIG")
path=$(grep "^abs_test|" "$CONFIG" | cut -d'|' -f2-)
if [ "$count" = "1" ] && [ "$path" = "$TEST_DIR_2" ]; then
    pass "Register overwrites existing shortcut without duplicates"
else
    fail "Register overwrites existing shortcut without duplicates"
fi

# 5. Register with path containing spaces
$GOTO_BIN -r space_test "$TEST_DIR_SPACES" >/dev/null 2>&1
resolved=$($GOTO_BIN space_test 2>/dev/null)
assert_eq "$TEST_DIR_SPACES" "$resolved" "Register and resolve path with spaces"

# 6. Register with nonexistent path (should fail)
$GOTO_BIN -r bad_test "/nonexistent/path/$$" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
    pass "Register with nonexistent path fails"
else
    fail "Register with nonexistent path fails" "non-zero exit" "exit 0"
fi

# 7. Register with empty name (should fail)
$GOTO_BIN -r "" "$TEST_DIR_1" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
    pass "Register with empty name fails"
else
    fail "Register with empty name fails" "non-zero exit" "exit 0"
fi

# 8. Register with invalid name characters (should fail)
$GOTO_BIN -r "bad name!" "$TEST_DIR_1" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
    pass "Register with invalid name (special chars) fails"
else
    fail "Register with invalid name (special chars) fails" "non-zero exit" "exit 0"
fi

# ════════════════════════════════════════════════════════════════
# RESOLVE TESTS
# ════════════════════════════════════════════════════════════════

# 9. Resolve existing shortcut
$GOTO_BIN -r resolve_me "$TEST_DIR_1" >/dev/null 2>&1
resolved=$($GOTO_BIN resolve_me 2>/dev/null)
assert_eq "$TEST_DIR_1" "$resolved" "Resolve existing shortcut"

# 10. Resolve nonexistent shortcut (should fail)
$GOTO_BIN "nonexistent_shortcut_$$" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
    pass "Resolve nonexistent shortcut fails"
else
    fail "Resolve nonexistent shortcut fails" "non-zero exit" "exit 0"
fi

# 11. Resolve shortcut pointing to deleted directory
TEMP_RESOLVE="$TEST_HOME/temp_resolve_dir"
mkdir -p "$TEMP_RESOLVE"
$GOTO_BIN -r temp_resolve "$TEMP_RESOLVE" >/dev/null 2>&1
rmdir "$TEMP_RESOLVE"
$GOTO_BIN temp_resolve >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
    pass "Resolve shortcut to deleted directory fails"
else
    fail "Resolve shortcut to deleted directory fails" "non-zero exit" "exit 0"
fi

# ════════════════════════════════════════════════════════════════
# SUBPATH TESTS
# ════════════════════════════════════════════════════════════════

# 12. Subpath navigation
$GOTO_BIN -r project "$TEST_HOME/test_project" >/dev/null 2>&1
resolved=$($GOTO_BIN project/src/lib 2>/dev/null)
assert_eq "$TEST_HOME/test_project/src/lib" "$resolved" "Subpath navigation (project/src/lib)"

# 13. Subpath to nonexistent subdirectory (should fail)
$GOTO_BIN project/nonexistent/path >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
    pass "Subpath to nonexistent subdirectory fails"
else
    fail "Subpath to nonexistent subdirectory fails" "non-zero exit" "exit 0"
fi

# ════════════════════════════════════════════════════════════════
# DELETE TESTS
# ════════════════════════════════════════════════════════════════

# 14. Delete with -d flag
$GOTO_BIN -r del_test_d "$TEST_DIR_1" >/dev/null 2>&1
$GOTO_BIN -d del_test_d >/dev/null 2>&1
if ! grep -q "^del_test_d|" "$CONFIG"; then
    pass "Delete with -d flag"
else
    fail "Delete with -d flag"
fi

# 15. Delete with -u flag (alias)
$GOTO_BIN -r del_test_u "$TEST_DIR_1" >/dev/null 2>&1
$GOTO_BIN -u del_test_u >/dev/null 2>&1
if ! grep -q "^del_test_u|" "$CONFIG"; then
    pass "Delete with -u flag (alias)"
else
    fail "Delete with -u flag (alias)"
fi

# 16. Delete nonexistent shortcut (should fail)
$GOTO_BIN -d "nonexistent_$$" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
    pass "Delete nonexistent shortcut fails"
else
    fail "Delete nonexistent shortcut fails" "non-zero exit" "exit 0"
fi

# ════════════════════════════════════════════════════════════════
# RENAME TESTS
# ════════════════════════════════════════════════════════════════

# 17. Rename existing shortcut
$GOTO_BIN -r rename_src "$TEST_DIR_1" >/dev/null 2>&1
$GOTO_BIN -R rename_src rename_dst >/dev/null 2>&1
if ! grep -q "^rename_src|" "$CONFIG" && grep -q "^rename_dst|${TEST_DIR_1}$" "$CONFIG"; then
    pass "Rename existing shortcut"
else
    fail "Rename existing shortcut"
fi

# 18. Rename nonexistent shortcut (should fail)
$GOTO_BIN -R "nonexistent_$$" new_name >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
    pass "Rename nonexistent shortcut fails"
else
    fail "Rename nonexistent shortcut fails" "non-zero exit" "exit 0"
fi

# 19. Rename to existing name (should fail)
$GOTO_BIN -r rename_a "$TEST_DIR_1" >/dev/null 2>&1
$GOTO_BIN -r rename_b "$TEST_DIR_2" >/dev/null 2>&1
$GOTO_BIN -R rename_a rename_b >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
    pass "Rename to existing name fails"
else
    fail "Rename to existing name fails" "non-zero exit" "exit 0"
fi

# ════════════════════════════════════════════════════════════════
# LIST TESTS
# ════════════════════════════════════════════════════════════════

# 20. List shows registered shortcuts
output=$($GOTO_BIN -l 2>&1)
assert_contains "resolve_me" "$output" "List shows registered shortcuts"

# 21. List shows (missing) for broken shortcuts
assert_contains "missing" "$output" "List shows (missing) for broken paths"

# 22. List with empty config
SAVED_CONFIG=$(cat "$CONFIG")
: > "$CONFIG"
output=$($GOTO_BIN -l 2>&1)
assert_contains "No shortcuts" "$output" "List with empty config shows message"
printf '%s' "$SAVED_CONFIG" > "$CONFIG"

# ════════════════════════════════════════════════════════════════
# CLEANUP TESTS
# ════════════════════════════════════════════════════════════════

# 23. Cleanup removes broken shortcuts
CLEANUP_DIR="$TEST_HOME/cleanup_test_dir"
mkdir -p "$CLEANUP_DIR"
$GOTO_BIN -r cleanup_good "$TEST_DIR_1" >/dev/null 2>&1
$GOTO_BIN -r cleanup_bad "$CLEANUP_DIR" >/dev/null 2>&1
rmdir "$CLEANUP_DIR"
output=$($GOTO_BIN -c 2>&1)
if ! grep -q "^cleanup_bad|" "$CONFIG" && grep -q "^cleanup_good|" "$CONFIG"; then
    pass "Cleanup removes broken shortcuts, keeps valid ones"
else
    fail "Cleanup removes broken shortcuts, keeps valid ones"
fi

# 24. Cleanup with no broken shortcuts
output=$($GOTO_BIN -c 2>&1)
assert_contains "Nothing to clean" "$output" "Cleanup with no broken shortcuts"

# ════════════════════════════════════════════════════════════════
# IMPORT / EXPORT TESTS
# ════════════════════════════════════════════════════════════════

# 25. Export produces valid config
export_file="$TEST_HOME/export.txt"
$GOTO_BIN --export > "$export_file" 2>/dev/null
lines=$(wc -l < "$export_file")
if [ "$lines" -gt 0 ]; then
    pass "Export produces output"
else
    fail "Export produces output" ">0 lines" "$lines lines"
fi

# 26. Import from file
import_file="$TEST_HOME/import.txt"
printf 'import_one|%s\nimport_two|%s\n' "$TEST_DIR_1" "$TEST_DIR_2" > "$import_file"
$GOTO_BIN --import "$import_file" >/dev/null 2>&1
if grep -q "^import_one|" "$CONFIG" && grep -q "^import_two|" "$CONFIG"; then
    pass "Import from file"
else
    fail "Import from file"
fi

# 27. Import nonexistent file (should fail)
$GOTO_BIN --import "/nonexistent/file_$$" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
    pass "Import nonexistent file fails"
else
    fail "Import nonexistent file fails" "non-zero exit" "exit 0"
fi

# ════════════════════════════════════════════════════════════════
# VERSION AND HELP TESTS
# ════════════════════════════════════════════════════════════════

# 28. --version outputs version
output=$($GOTO_BIN --version 2>&1)
assert_contains "goto" "$output" "--version outputs version string"

# 29. -V outputs version
output=$($GOTO_BIN -V 2>&1)
assert_contains "goto" "$output" "-V outputs version string"

# 30. --help outputs usage
output=$($GOTO_BIN --help 2>&1)
assert_contains "Usage" "$output" "--help outputs usage information"

# 31. -h outputs usage
output=$($GOTO_BIN -h 2>&1)
assert_contains "Usage" "$output" "-h outputs usage information"

# ════════════════════════════════════════════════════════════════
# EDGE CASE TESTS
# ════════════════════════════════════════════════════════════════

# 32. No arguments (should fail with usage error)
$GOTO_BIN >/dev/null 2>&1
rc=$?
if [ "$rc" -eq 2 ]; then
    pass "No arguments exits with code 2 (usage error)"
else
    fail "No arguments exits with code 2 (usage error)" "exit 2" "exit $rc"
fi

# 33. Unknown flag (should fail with usage error)
$GOTO_BIN --badoption >/dev/null 2>&1
rc=$?
if [ "$rc" -eq 2 ]; then
    pass "Unknown flag exits with code 2 (usage error)"
else
    fail "Unknown flag exits with code 2 (usage error)" "exit 2" "exit $rc"
fi

# 34. XDG_CONFIG_HOME is respected
ALT_XDG="$TEST_HOME/alt_xdg"
mkdir -p "$ALT_XDG"
XDG_CONFIG_HOME="$ALT_XDG" $GOTO_BIN -r xdg_test "$TEST_DIR_1" >/dev/null 2>&1
if [ -f "$ALT_XDG/goto/config" ] && grep -q "^xdg_test|" "$ALT_XDG/goto/config"; then
    pass "XDG_CONFIG_HOME is respected"
else
    fail "XDG_CONFIG_HOME is respected"
fi

# 35. Config file without trailing newline
printf 'notail|%s' "$TEST_DIR_1" > "$CONFIG"
output=$($GOTO_BIN -l 2>&1)
if printf '%s' "$output" | grep -q "notail"; then
    pass "Config without trailing newline is parsed correctly"
else
    fail "Config without trailing newline is parsed correctly"
fi

# Restore config for remaining tests
printf 'notail|%s\n' "$TEST_DIR_1" > "$CONFIG"

# 36. Non-TTY output has no ANSI codes
output=$($GOTO_BIN -l 2>&1 | cat)
if ! printf '%s' "$output" | grep -q "\\\\033"; then
    pass "Non-TTY output has no raw ANSI escape sequences"
else
    fail "Non-TTY output has no raw ANSI escape sequences"
fi

# ════════════════════════════════════════════════════════════════
# SUMMARY
# ════════════════════════════════════════════════════════════════

printf "\n# Results: %d/%d passed" "$tests_passed" "$tests_run"
if [ "$tests_failed" -gt 0 ]; then
    printf " (%d FAILED)" "$tests_failed"
fi
printf "\n"

if [ "$tests_failed" -gt 0 ]; then
    exit 1
fi
exit 0
