#!/bin/sh

echo "=================================="
echo "UBI Linux Shell Test Runner"
echo "=================================="
echo "Container: $(uname -a)"
echo "User: $(id)"
echo "Working directory: $(pwd)"
echo "Default /bin/sh points to: $(readlink -f /bin/sh)"
echo "=================================="

cd /mnt/pu-home/test || exit 1

# Run tests with available shells
echo "Running tests with default /bin/sh (bash)..."
/bin/sh ./runTests.sh
sh_exit_code=$?

echo ""
echo "Running tests with bash..."
/bin/bash ./runTests.sh
bash_exit_code=$?

echo ""
echo "=================================="
echo "Test Results Summary:"
echo "Default /bin/sh exit code: $sh_exit_code"
echo "Bash exit code: $bash_exit_code"
echo "=================================="

# Exit with non-zero if any test failed
if [ $sh_exit_code -ne 0 ] || [ $bash_exit_code -ne 0 ]; then
    exit 1
fi

exit 0
