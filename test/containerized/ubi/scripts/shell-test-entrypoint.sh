#!/bin/sh

# Get the shell type from environment variable
SHELL_TYPE="${SHELL_TYPE:-bash}"

echo "=================================="
echo "UBI Linux Single Shell Test Runner"
echo "=================================="
echo "Container: $(uname -a)"
echo "User: $(id)"
echo "Working directory: $(pwd)"
echo "Testing with shell: $SHELL_TYPE"
echo "Default /bin/sh points to: $(readlink -f /bin/sh)"
echo "=================================="

cd /mnt/pu-home/test || exit 1

# Run tests with the specified shell
case "$SHELL_TYPE" in
    sh)
        echo "Running tests with default /bin/sh..."
        /bin/sh ./runTests.sh
        ;;
    bash)
        echo "Running tests with bash..."
        /bin/bash ./runTests.sh
        ;;
    *)
        echo "Error: Unknown shell type: $SHELL_TYPE"
        echo "Supported shells: sh, bash"
        exit 1
        ;;
esac

exit_code=$?

echo ""
echo "=================================="
echo "Test completed with exit code: $exit_code"
echo "=================================="

exit $exit_code
