#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Test suite for string utilities (6.string.sh) using shunit2

# One-time setup - runs once before all tests
oneTimeSetUp() {
    export PU_HOME="${PU_HOME:-$(cd "$(dirname "$0")/.." && pwd)}"
    export PU_INIT_STRING="true"
    export PU_DEBUG_MODE="false" # Reduce noise in tests

    # Source the library once
    . "${PU_HOME}/code/1.init.sh"
}

# Test 01: pu_urlencode with simple string
testUrlencodeWithSimpleString() {
    __result=$(pu_urlencode "hello world")

    assertEquals "Space should be encoded as %20" "hello%20world" "${__result}"
}

# Test 02: pu_urlencode with special characters
testUrlencodeWithSpecialCharacters() {
    __result=$(pu_urlencode "hello&world")

    # & should be encoded as %26
    assertTrue "Should contain encoded ampersand" \
        "echo '${__result}' | grep -q '%26'"
}

# Test 03: pu_urlencode with safe characters
testUrlencodeWithSafeCharacters() {
    __result=$(pu_urlencode "hello-world_test.file~123")

    assertEquals "Safe characters should not be encoded" \
        "hello-world_test.file~123" "${__result}"
}

# Test 04: pu_urlencode with empty string
testUrlencodeWithEmptyString() {
    __result=$(pu_urlencode "")

    assertTrue "Empty string should produce empty result" \
        "[ -z '${__result}' ]"
}

# Test 05: pu_str_substitute basic substitution
testStrSubstituteBasicSubstitution() {
    __result=$(pu_str_substitute "hello world" " " "_")

    assertEquals "Space should be replaced with underscore" \
        "hello_world" "${__result}"
}

# Test 06: pu_str_substitute multiple character substitution
testStrSubstituteMultipleCharacters() {
    __result=$(pu_str_substitute "hello.world.txt" "." "-")

    assertEquals "Dots should be replaced with dashes" \
        "hello-world-txt" "${__result}"
}

# Test 07: pu_str_substitute with missing original string
testStrSubstituteWithMissingString() {
    pu_str_substitute "" " " "_" 2>/dev/null
    __result=$?

    assertEquals "Should return error code 1 for missing string" 1 ${__result}
}

# Test 08: pu_str_substitute with missing substitution chars
testStrSubstituteWithMissingSubstitution() {
    __result=$(pu_str_substitute "hello world" "" "")

    assertEquals "Should return original string when no substitution specified" \
        "hello world" "${__result}"
}

# Test 09: pu_str_substitute complex substitution
testStrSubstituteComplexSubstitution() {
    __result=$(pu_str_substitute "hello world.txt" " ." "_-")

    assertEquals "Complex substitution should work" \
        "hello_world-txt" "${__result}"
}

# Test 10: Function existence check
testStringFunctionsExist() {
    assertTrue "pu_urlencode should be defined" \
        "command -v pu_urlencode >/dev/null 2>&1"

    assertTrue "pu_urlencode_pipe should be defined" \
        "command -v pu_urlencode_pipe >/dev/null 2>&1"

    assertTrue "pu_str_substitute should be defined" \
        "command -v pu_str_substitute >/dev/null 2>&1"
}

# Test 11: pu_urlencode with URL-like string
testUrlencodeWithUrlLikeString() {
    __result=$(pu_urlencode "https://example.com/path?query=value")

    # Should encode : / ? =
    assertTrue "URL special characters should be encoded" \
        "echo '${__result}' | grep -q '%'"
}

# Test 12: pu_urlencode_pipe functionality
testUrlencodePipeFunctionality() {
    __result=$(echo "hello world" | pu_urlencode_pipe)

    assertEquals "Pipe encoding should work" "hello%20world" "${__result}"
}
