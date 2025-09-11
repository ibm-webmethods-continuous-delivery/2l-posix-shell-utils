#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# This module offers audited log and execution functions
# with the purpose of tracing scripted activity both
# for attended and unattended jobs

# Initialize audit session with directory structure and settings
pu_initAuditSession() {
  # Sets up debug environment variable, audit base directory, session timestamp, and session directory
  # Also initializes colored output setting from environment
  __log_prefix="audit.sh|pu_initAuditSession"
  __pu_debugOn="${PU_DEBUG_ON:-N}"
  __pu_auditBaseDir="${PU_AUDIT_BASE_DIR:-/tmp/pu-default-audit}"
  __pu_sessionTimestamp="${PU_SESSION_TIMESTAMP:-$(date +%y-%m-%dT%H.%M.%S)}"
  __pu_auditSessionDir="${__pu_auditBaseDir}/${__pu_sessionTimestamp}"
  mkdir -p "${__pu_auditSessionDir}"
  __pu_auditSessionLogFile="${__pu_auditSessionDir}/session.log"
  __pu_coloredOutput="${PU_COLORED_OUTPUT:-Y}" # Y or N
  # Color codes for console output
  __pu_clrReset='\033[0m'

  # Log session initialization
  pu_logI "${__log_prefix} ==============================================================="
  pu_logI "${__log_prefix} A new session had been initialized"
  pu_logI "${__log_prefix} Current timestamp is   : $(date +%y-%m-%dT%H.%M.%S)"
  pu_logI "${__log_prefix} Current session file is: ${__pu_auditSessionLogFile}"
  pu_logI "${__log_prefix} ==============================================================="

  unset __log_prefix
  return $?
}

# Execute command with controlled output redirection to audit files
pu_controlledExec() {
  # Args:
  #   $1 - command to execute in a controlled manner
  #   $2 - tag for trace files
  __pu_currentEpoch="$(date +%s)"
  __file_name="${__pu_auditSessionDir}/cExec_${__pu_currentEpoch}_${2}"
  eval "${1}" >"${__file_name}.out" 2>"${__file_name}.err"
  unset __pu_currentEpoch __file_name
  return $?
}

# Generate consistent timestamps with epoch time base for audit logging
_pu_getTimestamp() {
  # Uses epoch time as base for potential sub-second precision in future
  # Sets __pu_currentEpoch as side effect for advanced timing features
  __pu_currentTimestamp="$(date +%y\ %m\ %dT%H%M%S)"
  __cmd="printf '%s%X%s' ${__pu_currentTimestamp}"
  eval "${__cmd}"
  unset __pu_currentTimestamp __cmd
}

# audit log INFO level messages
pu_logI() {
  # Args:
  #   $1 - Message to log
  __msg=${1:-no\ message\?}
  __time=$(date +%H%M%S)
  echo "${__time}I|${__msg}"
  echo "${__time}I|${__msg}" >>"${__pu_auditSessionLogFile}"
  unset __msg __time
}

# Log warning level messages to audit session
pu_logW() {
  # Args:
  #   $1 - Message to log
  __msg=${1:-no\ message\?}
  __time=$(date +%H%M%S)
  if [ "${__pu_coloredOutput}" = "Y" ]; then
    __clr='\033[0;33m' # Yellow
    printf \
      "%s${__clr}W${__pu_clrReset}|${__clr}%s${__pu_clrReset}\n" \
      "${__time}" "${__msg}"
    unset __clr
  else
    echo "${__time}W|${__msg}"
  fi
  echo "${__time}W|${__msg}" >>"${__pu_auditSessionLogFile}"
  unset __msg __time
}

# Log error level messages to audit session
pu_logE() {
  # Args:
  #   $1 - Message to log
  __msg=${1:-no\ message\?}
  __time=$(date +%H%M%S)
  if [ "${__pu_coloredOutput}" = "Y" ]; then
    __clr='\033[0;31m' # Red
    printf \
      "%s${__clr}E${__pu_clrReset}|${__clr}%s${__pu_clrReset}\n" \
      "${__time}" "${__msg}"
    unset __clr
  else
    echo "${__time}E|${__msg}"
  fi
  echo "${__time}E|${__msg}" >>"${__pu_auditSessionLogFile}"
  unset __msg __time
}

# Log debug level messages to audit session when debug is enabled
pu_logD() {
  # Args:
  #   $1 - Message to log
  # Only logs when __pu_debugOn is Y
  if [ "${__pu_debugOn}" = "Y" ]; then
    __msg=${1:-no\ message\?}
    __time=$(date +%H%M%S)
    if [ "${__pu_coloredOutput}" = "Y" ]; then
      __clr='\033[0;36m' # Cyan
      printf \
        "%s${__clr}D${__pu_clrReset}|${__clr}%s${__pu_clrReset}\n" \
        "${__time}" "${__msg}"
      unset __clr
    else
      echo "${__time}D|${__msg}"
    fi
    echo "${__time}D|${__msg}" >>"${__pu_auditSessionLogFile}"
    unset __msg __time
  fi
}

# Initialize posix utilities with environment variables and audit session
pu_initAuditSession || exit $?

# Display and log PU environment variables when debug is enabled
pu_logEnv() {
  # Shows PU-prefixed environment variables to console and audit log
  __log_prefix="audit.sh|pu_logEnv"
  pu_logI "${__log_prefix} >>>>>>>>>>>>>>>> Begin Listing PU environment variables:"
  pu_logI "${__log_prefix} >>>>>>>>>>>> PU global public constants:"
  env | grep PU_ | grep -vi _PASS | grep -v _PU_ | sort
  env | grep PU_ | grep -vi _PASS | grep -v _PU_ | sort >>"${__pu_auditSessionLogFile}"
  pu_logI "${__log_prefix} >>>>>>>>>>>> __PU global private constants:"
  env | grep __PU_ | grep -vi _PASS | sort
  env | grep __PU_ | grep -vi _PASS | sort >>"${__pu_auditSessionLogFile}"
  pu_logI "${__log_prefix} >>>>>>>>>>>> pu_ global public variables:"
  env | grep pu_ | grep -v __pu_ | grep -vi _PASS | sort
  env | grep pu_ | grep -v __pu_ | grep -vi _PASS | sort >>"${__pu_auditSessionLogFile}"
  pu_logI "${__log_prefix} >>>>>>>>>>>> __pu_ global private variables:"
  env | grep __pu_ | grep -vi _PASS | sort
  env | grep __pu_ | grep -vi _PASS | sort >>"${__pu_auditSessionLogFile}"
  pu_logI "${__log_prefix} >>>>>>>>>>>>>>>> End Listing PU environment variables"
  unset __log_prefix
}

# Public accessor functions for controlled access to session state
pu_getAuditSessionDir() {
  # Returns the current audit session directory path
  printf '%s' "${__pu_auditSessionDir}"
}

pu_getAuditSessionFile() {
  # Returns the current audit session file path
  printf '%s' "${__pu_auditSessionLogFile}"
}

pu_getAuditBaseDir() {
  # Returns the current audit base directory path
  printf '%s' "${__pu_auditBaseDir}"
}

pu_getDebugOn() {
  # Returns the current debug state (Y or N)
  printf '%s' "${__pu_debugOn}"
}

pu_setDebugOn() {
  # Sets the debug state (Y or N)
  # Args:
  #   $1 - debug state (N for disabled, Y for enabled)
  __pu_debugOn="${1:-N}"
}

# Display all environment variables and log PU variables when debug is enabled
pu_logFullEnv() {
  # Shows all environment variables to console, logs only PU variables to audit log
  # Only active when __pu_debugOn is Y
  __log_prefix="audit.sh|pu_logFullEnv"
  if [ "${__pu_debugOn}" = "Y" ]; then
    pu_logD "${__log_prefix} -- Listing full environment... --"
    env | sort
    pu_logD "${__log_prefix} -- Listing PU environment... --"
    env | grep -i PU | sort >>"${__pu_auditSessionLogFile}"
  fi
  unset __log_prefix
}
