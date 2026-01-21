#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Test suite for data format utilities (7.data.sh) using shunit2

# One-time setup - runs once before all tests
oneTimeSetUp() {
    export PU_HOME="${PU_HOME:-$(cd "$(dirname "$0")/.." && pwd)}"
    export PU_INIT_DATA="true"
    export PU_DEBUG_MODE="false" # Reduce noise in tests

    # Source the library once
    . "${PU_HOME}/code/1.init.sh"

    # Create temp directory for test files
    __test_dir="${PU_HOME}/local/test_$$"
    mkdir -p "${__test_dir}"
}

# One-time teardown - runs once after all tests
oneTimeTearDown() {
    # Clean up test files
    if [ -d "${__test_dir}" ]; then
        rm -rf "${__test_dir}"
    fi
}

# Test 01: pu_csv_to_lines with simple CSV
testCsvToLinesWithSimpleCSV() {
    __result=$(pu_csv_to_lines "apple,banana,cherry")
    __line_count=$(echo "${__result}" | wc -l)

    assertEquals "CSV should convert to 3 lines" 3 ${__line_count}
}

# Test 02: pu_csv_to_lines with custom delimiter
testCsvToLinesWithCustomDelimiter() {
    __result=$(pu_csv_to_lines "apple|banana|cherry" "|")
    __line_count=$(echo "${__result}" | wc -l)

    assertEquals "CSV with custom delimiter should convert to 3 lines" 3 ${__line_count}
}

# Test 03: pu_csv_to_lines with missing argument
testCsvToLinesWithMissingArgument() {
    pu_csv_to_lines "" 2>/dev/null
    __result=$?

    assertEquals "Should return error code 1 for missing argument" 1 ${__result}
}

# Test 04: pu_csv_to_lines with single value
testCsvToLinesWithSingleValue() {
    __result=$(pu_csv_to_lines "apple")
    __line_count=$(echo "${__result}" | wc -l)

    assertEquals "Single value should produce 1 line" 1 ${__line_count}
}

# Test 05: pu_lines_to_csv with test file
testLinesToCsvWithTestFile() {
    __test_file="${__test_dir}/test_lines.txt"
    cat >"${__test_file}" <<EOF
apple
banana
cherry
EOF

    __result=$(pu_lines_to_csv "${__test_file}")

    assertEquals "Lines should convert to CSV" "apple,banana,cherry" "${__result}"
}

# Test 06: pu_lines_to_csv with custom delimiter
testLinesToCsvWithCustomDelimiter() {
    __test_file="${__test_dir}/test_lines2.txt"
    cat >"${__test_file}" <<EOF
apple
banana
cherry
EOF

    __result=$(pu_lines_to_csv "${__test_file}" "|")

    assertEquals "Lines should convert to CSV with custom delimiter" \
        "apple|banana|cherry" "${__result}"
}

# Test 07: pu_lines_to_csv with missing file
testLinesToCsvWithMissingFile() {
    pu_lines_to_csv "/nonexistent/file.txt" 2>/dev/null
    __result=$?

    assertEquals "Should return error code 1 for missing file" 1 ${__result}
}

# Test 08: pu_lines_to_csv with empty argument
testLinesToCsvWithEmptyArgument() {
    pu_lines_to_csv "" 2>/dev/null
    __result=$?

    assertEquals "Should return error code 1 for empty argument" 1 ${__result}
}

# Test 09: pu_parse_yaml with simple YAML
testParseYamlWithSimpleYAML() {
    __test_yaml="${__test_dir}/test_config.yaml"
    cat >"${__test_yaml}" <<EOF
database:
  host: localhost
  port: 5432
app:
  name: testapp
EOF

    __result=$(pu_parse_yaml "${__test_yaml}" "TEST_")

    assertTrue "YAML should parse correctly" \
        "echo '${__result}' | grep -q 'TEST_database_host=\"localhost\"'"
}

# Test 10: pu_load_env_from_yaml
testLoadEnvFromYaml() {
    __test_yaml="${__test_dir}/test_env.yaml"
    cat >"${__test_yaml}" <<EOF
database:
  host: localhost
  port: 5432
EOF

    pu_load_env_from_yaml "${__test_yaml}" "TESTENV_"

    assertEquals "Database host should be loaded" "localhost" "${TESTENV_database_host}"
    assertEquals "Database port should be loaded" "5432" "${TESTENV_database_port}"

    # Cleanup
    unset TESTENV_database_host TESTENV_database_port
}

# Test 11: pu_parse_yaml with missing file
testParseYamlWithMissingFile() {
    pu_parse_yaml "/nonexistent/file.yaml" 2>/dev/null
    __result=$?

    assertEquals "Should return error code 1 for missing file" 1 ${__result}
}

# Test 12: pu_load_env_from_yaml with missing file
testLoadEnvFromYamlWithMissingFile() {
    pu_load_env_from_yaml "/nonexistent/file.yaml" 2>/dev/null
    __result=$?

    assertEquals "Should return error code 1 for missing file" 1 ${__result}
}

# Test 13: Function existence check
testDataFormatFunctionsExist() {
    assertTrue "pu_csv_to_lines should be defined" \
        "command -v pu_csv_to_lines >/dev/null 2>&1"

    assertTrue "pu_lines_to_csv should be defined" \
        "command -v pu_lines_to_csv >/dev/null 2>&1"

    assertTrue "pu_parse_yaml should be defined" \
        "command -v pu_parse_yaml >/dev/null 2>&1"

    assertTrue "pu_load_env_from_yaml should be defined" \
        "command -v pu_load_env_from_yaml >/dev/null 2>&1"
}
