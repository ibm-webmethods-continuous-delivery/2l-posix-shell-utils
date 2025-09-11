#!/bin/sh

echo "=================================="
echo "Alpine Linux Multi-Shell Test Runner"
echo "=================================="
echo "Container: $(uname -a)"
echo "User: $(id)"
echo "Working directory: $(pwd)"
echo "Available shells:"
echo "  /bin/bash: $(test -x /bin/bash && echo 'YES' || echo 'NO')"
echo "  /usr/bin/dash: $(test -x /usr/bin/dash && echo 'YES' || echo 'NO')"
echo "  /bin/ash: $(test -x /bin/ash && echo 'YES' || echo 'NO')"
echo "  /bin/sh -> $(readlink -f /bin/sh)"
echo "=================================="

cd /mnt/pu-home/test || exit 1

# Run tests with different shells
echo "Running tests with bash..."
/bin/bash ./runTests.sh
bash_exit_code=$?

echo ""
echo "Running tests with dash..."
/usr/bin/dash ./runTests.sh
dash_exit_code=$?

echo ""
echo "Running tests with ash..."
/bin/ash ./runTests.sh
ash_exit_code=$?

echo ""
echo "=================================="
echo "Test Results Summary:"
echo "Bash exit code: $bash_exit_code"
echo "Dash exit code: $dash_exit_code"
echo "Ash exit code: $ash_exit_code"
echo "=================================="

# Exit with non-zero if any test failed
if [ $bash_exit_code -ne 0 ] || [ $dash_exit_code -ne 0 ] || [ $ash_exit_code -ne 0 ]; then
    exit 1
fi

exit 0
