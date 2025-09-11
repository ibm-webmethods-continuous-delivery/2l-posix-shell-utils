#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

testFrameworkCorrectInitialization(){
    assertTrue \
    "PU_HOME is not set or not pointing to a directory! Current Value is: --${PU_HOME}--" \
    "[ -d \"${PU_HOME}\" ]"

    assertTrue \
    "audit.sh file not existent or not readable!" \
    "[ -r \"${PU_HOME}/code/audit.sh\" ]"
}

testAuditSessionInitialization(){
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

testLoggingFunction(){
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