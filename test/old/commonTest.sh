#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Test suite for common utilities (4.common.sh) using shunit2

# One-time setup - runs once before all tests
oneTimeSetUp() {
    export PU_HOME="${PU_HOME:-$(cd "$(dirname "$0")/.." && pwd)}"
    export PU_INIT_COMMON="true"
    export PU_DEBUG_MODE="true" # Enable for debug function tests

    # Source the library once
    . "${PU_HOME}/code/1.init.sh"
}

# Test 01: pu_log_env_filtered basic functionality
testLogEnvFilteredBasicFunctionality() {
    # Set some test environment variables
    export PU_TEST_VAR="test_value"
    export PU_TEST_PASSWORD="secret123"
    export PU_TEST_DBPASS="dbsecret"

    # Call the function (it should filter passwords)
    pu_log_env_filtered "PU_TEST" >/dev/null 2>&1
    __result=$?

    assertEquals "pu_log_env_filtered should execute successfully" 0 ${__result}

    # Cleanup
    unset PU_TEST_VAR PU_TEST_PASSWORD PU_TEST_DBPASS
}

# Test 02: pu_log_env_filtered with debug mode off
testLogEnvFilteredWithDebugModeOff() {
    __save_debug=${__pu_debug_mode}
    __pu_debug_mode="false"

    export PU_TEST_VAR2="test_value2"
    pu_log_env_filtered "PU_TEST" >/dev/null 2>&1
    __result=$?

    assertEquals "Should handle debug mode off correctly" 0 ${__result}

    __pu_debug_mode=${__save_debug}
    unset PU_TEST_VAR2 __save_debug
}

# Test 03: pu_log_env_filtered with custom prefix
testLogEnvFilteredWithCustomPrefix() {
    export CUSTOM_VAR="custom_value"
    export CUSTOM_PASSWORD="secret"

    pu_log_env_filtered "CUSTOM" >/dev/null 2>&1
    __result=$?

    assertEquals "Should work with custom prefix" 0 ${__result}

    unset CUSTOM_VAR CUSTOM_PASSWORD
}

# Test 04: pu_log_env_filtered with default prefix
testLogEnvFilteredWithDefaultPrefix() {
    export PU_DEFAULT_TEST="value"

    pu_log_env_filtered >/dev/null 2>&1
    __result=$?

    assertEquals "Should use default PU prefix" 0 ${__result}

    unset PU_DEFAULT_TEST
}

# Test 05: pu_debug_suspend function exists
testDebugSuspendFunctionExists() {
    assertTrue "pu_debug_suspend function should be defined" \
        "command -v pu_debug_suspend >/dev/null 2>&1"
}

# Test 06: pu_debug_suspend with debug mode off (should not suspend)
testDebugSuspendWithDebugModeOff() {
    __save_debug=${__pu_debug_mode}
    __pu_debug_mode="false"

    # This should return immediately since debug is off
    # We'll run it in a subshell with timeout to ensure it doesn't hang
    (
        pu_debug_suspend
        exit 0
    ) &
    __pid=$!

    # Wait briefly
    sleep 1

    # Check if process is still running
    if kill -0 ${__pid} 2>/dev/null; then
        # Process still running, kill it
        kill ${__pid} 2>/dev/null
        wait ${__pid} 2>/dev/null
        fail "pu_debug_suspend should not suspend when debug mode is off"
    else
        # Process finished - this is expected
        wait ${__pid} 2>/dev/null
        assertTrue "pu_debug_suspend correctly skips suspension when debug is off" true
    fi

    __pu_debug_mode=${__save_debug}
    unset __save_debug __pid
}

# Test 07: pu_read_secret_from_user function exists
testReadSecretFromUserFunctionExists() {
    assertTrue "pu_read_secret_from_user function should be defined" \
        "command -v pu_read_secret_from_user >/dev/null 2>&1"
}

# Test 08: Function existence check
testCommonUtilityFunctionsExist() {
    assertTrue "pu_read_secret_from_user should be defined" \
        "command -v pu_read_secret_from_user >/dev/null 2>&1"

    assertTrue "pu_log_env_filtered should be defined" \
        "command -v pu_log_env_filtered >/dev/null 2>&1"

    assertTrue "pu_debug_suspend should be defined" \
        "command -v pu_debug_suspend >/dev/null 2>&1"
}

# Test 09: Verify password filtering in log output
testPasswordFilteringInLogOutput() {
    export PU_FILTER_TEST_PASS="should_not_appear"
    export PU_FILTER_TEST_VAR="should_appear"

    # Capture output
    __output=$(pu_log_env_filtered "PU_FILTER" 2>&1)

    # Check that regular var appears but password does not
    assertTrue "Regular variable should appear" \
        "echo '${__output}' | grep -q 'PU_FILTER_TEST_VAR'"

    assertFalse "Password variable should be filtered" \
        "echo '${__output}' | grep -q 'PU_FILTER_TEST_PASS'"

    unset PU_FILTER_TEST_PASS PU_FILTER_TEST_VAR __output
}
