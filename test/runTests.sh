#!/bin/sh

# shellcheck source-path=SCRIPTDIR/..

__all_tests_err_no=0

__prt_test_head() {
  echo "=============== runTests.sh BEGIN Test ${1} ===================="
}

__prt_test_end() {
  echo "=============== runTests.sh  END  Test ${1} ===================="
}

############ Constants set 1
__prt_test_head "Constants SET #01"
export PU_DEBUG_ON=true
./runTestsInner.sh
__all_tests_err_no=$((__all_tests_err_no + $?))
__prt_test_end "Constants SET #01"

############ Constants set 2
__prt_test_head "Constants SET #02"
export PU_DEBUG_ON=false
./runTestsInner.sh
__all_tests_err_no=$((__all_tests_err_no + $?))
__prt_test_end "Constants SET #02"

############ Constants set 3
__prt_test_head "Constants SET #03"
unset PU_DEBUG_ON
./runTestsInner.sh
__all_tests_err_no=$((__all_tests_err_no + $?))
__prt_test_end "Constants SET #03"

echo "=============== runTests.sh Number of failures: ${__all_tests_err_no} ===================="
exit ${__all_tests_err_no}
