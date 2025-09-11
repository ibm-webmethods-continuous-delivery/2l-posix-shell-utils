#!/bin/sh

# Get the shell type from environment variable
SHELL_TYPE="${SHELL_TYPE:-bash}"

echo "=================================="
echo "Alpine Linux Single Shell Test Runner"
echo "=================================="
echo "Container: $(uname -a)"
echo "User: $(id)"
echo "Working directory: $(pwd)"
echo "Testing with shell: $SHELL_TYPE"
echo "Available shells:"
echo "  /bin/bash: $(test -x /bin/bash && echo 'YES' || echo 'NO')"
echo "  /usr/bin/dash: $(test -x /usr/bin/dash && echo 'YES' || echo 'NO')"
echo "  /bin/ash: $(test -x /bin/ash && echo 'YES' || echo 'NO')"
echo "  /bin/sh -> $(readlink -f /bin/sh)"
echo "=================================="

cd /mnt/pu-home/test || exit 1

# Run tests with the specified shell
case "$SHELL_TYPE" in
    bash)
        echo "Running tests with bash..."
        /bin/bash ./runTests.sh
        ;;
    dash)
        echo "Running tests with dash..."
        /usr/bin/dash ./runTests.sh
        ;;
    ash)
        echo "Running tests with ash..."
        /bin/ash ./runTests.sh
        ;;
    *)
        echo "Error: Unknown shell type: $SHELL_TYPE"
        echo "Supported shells: bash, dash, ash"
        exit 1
        ;;
esac

exit_code=$?

echo ""
echo "=================================="
echo "Test completed with exit code: $exit_code"
echo "=================================="

exit $exit_code
