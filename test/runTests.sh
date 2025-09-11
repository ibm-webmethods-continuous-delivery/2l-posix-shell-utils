#!/bin/sh

# Enhanced test runner with shell compatibility checks
export PU_HOME="${PU_HOME:-..}" # Default to parent directory if not set, i.e. we are running from test/

errNo=0

shunit2 auditTest.sh || errNo=$((errNo + 1))

shunit2 ingesterTest.sh || errNo=$((errNo + 1))

echo "Test run completed with ${errNo} errors."