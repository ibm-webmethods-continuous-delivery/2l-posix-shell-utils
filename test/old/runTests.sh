#!/bin/sh

# Enhanced test runner with shell compatibility checks
export PU_HOME="${PU_HOME:-..}" # Default to parent directory if not set, i.e. we are running from test/

errNo=0

echo "=========================================="
echo "Running POSIX Shell Utils Test Suite"
echo "=========================================="
echo ""

# Run all shunit2-based tests
echo "Running audit module tests..."
shunit2 auditTest.sh || errNo=$((errNo + 1))

echo ""
echo "Running ingester module tests..."
shunit2 ingesterTest.sh || errNo=$((errNo + 1))

echo ""
echo "Running network utilities tests..."
shunit2 networkTest.sh || errNo=$((errNo + 1))

echo ""
echo "Running string utilities tests..."
shunit2 stringTest.sh || errNo=$((errNo + 1))

echo ""
echo "Running data format utilities tests..."
shunit2 dataTest.sh || errNo=$((errNo + 1))

echo ""
echo "Running common utilities tests..."
shunit2 commonTest.sh || errNo=$((errNo + 1))

echo ""
echo "=========================================="
echo "Test run completed with ${errNo} test suite(s) failed."
echo "=========================================="

exit ${errNo}
