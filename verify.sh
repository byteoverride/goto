#!/bin/bash

# Setup
export HOME=/tmp/goto_test_home
rm -rf $HOME
mkdir -p $HOME/.config/goto
GOTO_BIN="$(pwd)/goto"

echo "Testing goto..."

# 1. Register absolute path
$GOTO_BIN -r test_abs $(pwd)
if grep -q "test_abs|$(pwd)" $HOME/.config/goto/config; then
    echo "✅ Register absolute path passed"
else
    echo "❌ Register absolute path failed"
fi

# 2. Register relative path
mkdir -p /tmp/goto_test_dir
cd /tmp/goto_test_dir
$GOTO_BIN -r test_rel .
if grep -q "test_rel|/tmp/goto_test_dir" $HOME/.config/goto/config; then
    echo "✅ Register relative path passed"
else
    echo "❌ Register relative path failed (got $(grep test_rel $HOME/.config/goto/config))"
fi
cd - > /dev/null

# 3. List
count=$($GOTO_BIN -l | grep "test_" | wc -l)
if [ "$count" -ge 2 ]; then
    echo "✅ List passed"
else
    echo "❌ List failed"
fi

# 4. Resolve
res=$($GOTO_BIN test_abs)
if [ "$res" == "$(pwd)" ]; then
    echo "✅ Resolve passed"
else
    echo "❌ Resolve failed"
fi

# 5. Delete (-d)
$GOTO_BIN -d test_abs >/dev/null
if ! grep -q "test_abs" $HOME/.config/goto/config; then
    echo "✅ Delete (-d) passed"
else
    echo "❌ Delete (-d) failed"
fi

# 6. Delete (-u)
$GOTO_BIN -u test_rel >/dev/null
if ! grep -q "test_rel" $HOME/.config/goto/config; then
    echo "✅ Delete (-u) passed"
else
    echo "❌ Delete (-u) failed"
fi

rm -rf $HOME
# Cleanup temp dir
rmdir /tmp/goto_test_dir
echo "Done."
