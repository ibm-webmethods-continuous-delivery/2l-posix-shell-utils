#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

testFrameworkCorrectInitialization() {
    assertTrue \
        "PU_HOME is not set or not pointing to a directory! Current Value is: --${PU_HOME}--" \
        "[ -d \"${PU_HOME}\" ]"

    assertTrue \
        "audit.sh file not existent or not readable!" \
        "[ -r \"${PU_HOME}/code/audit.sh\" ]"
}

testAuditSessionInitialization() {
    # Source the audit script to access its functions

    # shellcheck source=SCRIPTDIR/../code/audit.sh
    . "${PU_HOME}/code/audit.sh"

    assertTrue \
        "pu_auditBaseDir should be set after initialization" \
        "[ -n \"$(pu_getAuditBaseDir)\" ]"

    assertTrue \
        "Audit session directory should be accessible and non-empty" \
        "[ -n \"$(pu_getAuditSessionDir)\" ]"

    assertTrue \
        "Audit session directory should exist after initialization" \
        "[ -d \"$(pu_getAuditSessionDir)\" ]"
}

testLoggingFunction() {
    # Source the audit script to access its functions
    # shellcheck source=SCRIPTDIR/../code/audit.sh
    . "${PU_HOME}/code/audit.sh"

    # Test that pu_logI creates log entries
    __pu_testLogging_message="Test log message for shunit2"
    pu_logI "${__pu_testLogging_message}"

    assertTrue \
        "Log file should exist after logging" \
        "[ -f \"$(pu_getAuditSessionDir)/session.log\" ]"

    assertTrue \
        "Log file should contain the test message" \
        "grep -q \"${__pu_testLogging_message}\" \"$(pu_getAuditSessionDir)/session.log\""
}

testColoredLogs() {
    __test_msg="Default settings: debug=${__pu_debugOn} colored=${__pu_coloredOutput}"
    pu_logD "DBG - ${__test_msg}"
    pu_logE "ERR - ${__test_msg}"
    pu_logI "INF - ${__test_msg}"
    pu_logW "WRN - ${__test_msg}"

    __save_dbg=${__pu_debugOn}
    __save_colored=${__pu_coloredOutput}

    for __pu_coloredOutput in "Y" "N"; do
        pu_logI "Testing for __pu_coloredOutput=${__pu_coloredOutput}"
        for __pu_debugOn in "Y" "N"; do
            pu_logI "Testing for __pu_coloredOutput=${__pu_coloredOutput} and __pu_debugOn=${__pu_debugOn}"
            pu_logD "Debug Message"
            pu_logE "Error Message"
            pu_logW "Warning Message"
        done
    done

    # restore and exit
    __pu_debugOn=${__save_dbg}
    __pu_coloredOutput=${__save_colored}
    unset __save_dbg __save_colored __test_msg
}
