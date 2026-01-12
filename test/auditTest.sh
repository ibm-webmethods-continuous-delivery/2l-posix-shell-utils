#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

testFrameworkCorrectInitialization() {
    assertTrue \
        "PU_HOME is not set or not pointing to a directory! Current Value is: --${PU_HOME}--" \
        "[ -d \"${PU_HOME}\" ]"

    assertTrue \
        "2.audit.sh file not existent or not readable!" \
        "[ -r \"${PU_HOME}/code/2.audit.sh\" ]"
}

testAuditSessionInitialization() {
    # Source the audit script to access its functions

    # shellcheck source=SCRIPTDIR/../code/2.audit.sh
    . "${PU_HOME}/code/1.init.sh"

    assertTrue \
        "__pu_audit_base_dir should be set after initialization" \
        "[ -n \"${__pu_audit_base_dir}\" ]"

    assertTrue \
        "Audit session directory should be accessible and non-empty" \
        "[ -n \"${__pu_audit_session_dir}\" ]"

    assertTrue \
        "Audit session directory should exist after initialization" \
        "[ -d \"${__pu_audit_session_dir}\" ]"
}

testLoggingFunction() {
    # Source the audit script to access its functions
    # shellcheck source=SCRIPTDIR/../code/2.audit.sh
    . "${PU_HOME}/code/1.init.sh"

    # Test that pu_log_i creates log entries
    __pu_testLogging_message="Test log message for shunit2"
    pu_log_i "${__pu_testLogging_message}"

    assertTrue \
        "Log file should exist after logging" \
        "[ -f \"${__pu_audit_session_dir}/session.log\" ]"

    assertTrue \
        "Log file should contain the test message" \
        "grep -q \"${__pu_testLogging_message}\" \"${__pu_audit_session_dir}/session.log\""
}

testColoredLogs() {
    __test_msg="Default settings: debug=${__pu_debug_mode} colored=${__pu_colored_mode}"
    pu_log_d "DBG - ${__test_msg}"
    pu_log_e "ERR - ${__test_msg}"
    pu_log_i "INF - ${__test_msg}"
    pu_log_w "WRN - ${__test_msg}"

    __save_dbg=${__pu_debug_mode}
    __save_colored=${__pu_colored_mode}

    for __pu_colored_mode in "true" "false"; do
        pu_log_i "Testing for __pu_colored_mode=${__pu_colored_mode}"
        for __pu_debug_mode in "true" "false"; do
            pu_log_i "Testing for __pu_colored_mode=${__pu_colored_mode} and __pu_debug_mode=${__pu_debug_mode}"
            pu_log_d "Debug Message"
            pu_log_e "Error Message"
            pu_log_w "Warning Message"
        done
    done

    # restore and exit
    __pu_debug_mode=${__save_dbg}
    __pu_colored_mode=${__save_colored}
    unset __save_dbg __save_colored __test_msg
}
