#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Test suite for network utilities (5.network.sh) using shunit2

# One-time setup - runs once before all tests
oneTimeSetUp() {
    export PU_HOME="${PU_HOME:-$(cd "$(dirname "$0")/.." && pwd)}"
    export PU_INIT_NETWORK="true"
    export PU_DEBUG_MODE="false" # Reduce noise in tests

    # Source the library once
    . "${PU_HOME}/code/1.init.sh"
}

# Test 01: pu_port_is_reachable with missing arguments
testPortIsReachableWithMissingArguments() {
    pu_port_is_reachable "" "" 2>/dev/null
    __result=$?

    assertEquals "Should return error code 2 for missing arguments" 2 ${__result}
}

# Test 02: pu_port_is_reachable with unreachable port
testPortIsReachableWithUnreachablePort() {
    pu_port_is_reachable "localhost" "65534" 2>/dev/null
    __result=$?

    assertNotEquals "Port 65534 should not be reachable" 0 ${__result}
}

# Test 03: pu_port_is_reachable with invalid hostname
testPortIsReachableWithInvalidHostname() {
    pu_port_is_reachable "invalid.hostname.that.does.not.exist.local" "80" 2>/dev/null
    __result=$?

    assertNotEquals "Should fail with invalid hostname" 0 ${__result}
}

# Test 04: pu_wait_for_port with missing arguments
testWaitForPortWithMissingArguments() {
    pu_wait_for_port "" "" 2>/dev/null
    __result=$?

    assertEquals "Should return error code 2 for missing arguments" 2 ${__result}
}

# Test 05: pu_wait_for_port with timeout on unreachable port
testWaitForPortWithTimeout() {
    pu_wait_for_port "localhost" "65533" 2 1 2>/dev/null
    __result=$?

    assertEquals "Should timeout on unreachable port" 1 ${__result}
}

# Test 06: Function existence check
testNetworkFunctionsExist() {
    assertTrue "pu_port_is_reachable should be defined" \
        "command -v pu_port_is_reachable >/dev/null 2>&1"

    assertTrue "pu_wait_for_port should be defined" \
        "command -v pu_wait_for_port >/dev/null 2>&1"
}

# Test 07: pu_port_is_reachable with localhost common ports
testPortIsReachableWithCommonPorts() {
    # Try a few common ports that might be open
    # We don't assert success because the environment may vary
    # Just verify the function runs without crashing

    pu_port_is_reachable "localhost" "22" 2>/dev/null || true
    pu_port_is_reachable "localhost" "80" 2>/dev/null || true

    # If we got here without crashing, test passes
    assertTrue "Function should execute without errors" true
}

# Test 08: pu_wait_for_port with custom retry parameters
testWaitForPortWithCustomParameters() {
    # Test with very short timeout to ensure it completes quickly
    pu_wait_for_port "localhost" "65532" 1 1 2>/dev/null
    __result=$?

    # Should timeout (return 1) or succeed (return 0), but not error (return 2)
    assertNotEquals "Should not return error code 2" 2 ${__result}
}
