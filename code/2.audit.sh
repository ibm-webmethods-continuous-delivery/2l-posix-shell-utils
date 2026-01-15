#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# This module offers audited log and execution functions
# with the purpose of tracing scripted activity both
# for attended and unattended jobs

if [ -z ${__pu_clr_reset+x} ]; then
  printf "FATAL: source the file 1.init.sh first"
  exit 201
fi

# Function 01 Initialize audit session with directory structure and settings
pu_audit_init_session() {
  # Sets up debug environment variable, audit base directory, session timestamp, and session directory
  # Also initializes colored output setting from environment
  __pu_audit_base_dir="${PU_AUDIT_BASE_DIR:-/tmp/pu-default-audit}"
  __pu_session_timestamp="${PU_SESSION_TIMESTAMP:-$(date +%y-%m-%dT%H.%M.%S)}"
  __pu_audit_session_dir="${__pu_audit_base_dir}/${__pu_session_timestamp}"
  mkdir -p "${__pu_audit_session_dir}"
  __pu_audit_session_file="${__pu_audit_session_dir}/session.log"
  # Color codes for console output
  __pu_clr_reset='\033[0m'

  # Log session initialization
  pu_log_i "PU2|01| ==============================================================="
  pu_log_i "PU2|01| A new session had been initialized"
  pu_log_i "PU2|01| Current timestamp is   : $(date +%y-%m-%dT%H.%M.%S)"
  pu_log_i "PU2|01| Current session file is: ${__pu_audit_session_file}"
  pu_log_i "PU2|01| =========> Received audit session variables:"
  pu_log_i "PU2|01| PU_AUDIT_BASE_DIR=${PU_AUDIT_BASE_DIR}"
  pu_log_i "PU2|01| PU_SESSION_TIMESTAMP=${PU_SESSION_TIMESTAMP}"
  pu_log_i "PU2|01| =========> Effective audit session variables:"
  pu_log_i "PU2|01| __pu_audit_base_dir=${__pu_audit_base_dir}"
  pu_log_i "PU2|01| __pu_audit_session_dir=${__pu_audit_session_dir}"
  pu_log_i "PU2|01| __pu_colored_mode=${__pu_colored_mode}"
  pu_log_i "PU2|01| __pu_debug_mode=${__pu_debug_mode}"
  pu_log_i "PU2|01| __pu_session_timestamp=${__pu_session_timestamp}"
  pu_log_i "PU2|01| ==============================================================="

  unset __log_prefix
  return $?
}

# Function 02 Execute command with controlled output redirection to audit files
pu_controlled_exec() {
  # Args:
  #   $1 - command to execute in a controlled manner
  #   $2 - tag for trace files
  __pu_current_epoch="$(date +%s)"
  __file_name="${__pu_audit_session_dir}/cExec_${__pu_current_epoch}_${2}"
  eval "${1}" >"${__file_name}.out" 2>"${__file_name}.err"
  unset __pu_current_epoch __file_name
  return $?
}

# Function 03 Generate consistent timestamps with epoch time base for audit logging
_pu_get_timestamp() {
  # Uses epoch time as base for potential sub-second precision in future
  # Sets __pu_current_epoch as side effect for advanced timing features
  __pu_current_timestamp="$(date +%y\ %m\ %dT%H%M%S)"
  __cmd="printf '%s%X%s' ${__pu_current_timestamp}"
  eval "${__cmd}"
  unset __pu_current_timestamp __cmd
}

# Function 04 audit log INFO level messages
pu_log_i() {
  # Args:
  #   $1 - Message to log
  __msg=${1:-no\ message\?}
  __time=$(date -u +%H%M%S)
  echo "${__time}I ${__msg}" >&2
  echo "${__time}I ${__msg}" >>"${__pu_audit_session_file}"
  unset __msg __time
}

# Function 05 Log warning level messages to audit session
pu_log_w() {
  # Args:
  #   $1 - Message to log
  __msg=${1:-no\ message\?}
  __time=$(date -u +%H%M%S)
  if [ "${__pu_colored_mode}" = "true" ]; then
    __clr='\033[0;33m' # Yellow
    printf "%s%bW%b %b%s%b\n" \
      "${__time}" "${__clr}" "${__pu_clr_reset}" "${__clr}" "${__msg}" "${__pu_clr_reset}" >&2
    unset __clr
  else
    echo "${__time}W ${__msg}" >&2
  fi
  echo "${__time}W ${__msg}" >>"${__pu_audit_session_file}"
  unset __msg __time
}

# Function 06 Log error level messages to audit session
pu_log_e() {
  # Args:
  #   $1 - Message to log
  __msg=${1:-no\ message\?}
  __time=$(date -u +%H%M%S)
  if [ "${__pu_colored_mode}" = "true" ]; then
    __clr='\033[0;31m' # Red
    printf "%s%bE%b %b%s%b\n" \
      "${__time}" "${__clr}" "${__pu_clr_reset}" "${__clr}" "${__msg}" "${__pu_clr_reset}" >&2
    unset __clr
  else
    echo "${__time}E ${__msg}" >&2
  fi
  echo "${__time}E ${__msg}" >>"${__pu_audit_session_file}"
  unset __msg __time
}

# Function 07 Log debug level messages to audit session when debug is enabled
pu_log_d() {
  # Args:
  #   $1 - Message to log
  # Only logs when __pu_debug_mode is true
  if [ "${__pu_debug_mode}" = "true" ]; then
    __msg=${1:-no\ message\?}
    __time=$(date -u +%H%M%S)
    if [ "${__pu_colored_mode}" = "true" ]; then
      __clr='\033[0;36m' # Cyan
      printf "%s%bD%b %b%s%b\n" \
        "${__time}" "${__clr}" "${__pu_clr_reset}" "${__clr}" "${__msg}" "${__pu_clr_reset}" >&2
      unset __clr
    else
      echo "${__time}D ${__msg}" >&2
    fi
    echo "${__time}D ${__msg}" >>"${__pu_audit_session_file}"
    unset __msg __time
  fi
}

# Initialize posix utilities with environment variables and audit session
pu_audit_init_session || exit $?

# Function 08 Display and log PU environment variables when debug is enabled
pu_log_env() {
  # Shows PU-prefixed environment variables to console and audit log
  pu_log_i "PU2|08| >>>>>>>>>>>>>>>> Begin Listing PU environment variables:"
  pu_log_i "PU2|08| >>>>>>>>>>>> PU global public constants:"
  env | grep PU_ | grep -vi _PASS | grep -v _PU_ | sort
  env | grep PU_ | grep -vi _PASS | grep -v _PU_ | sort >>"${__pu_audit_session_file}"
  pu_log_i "PU2|08| >>>>>>>>>>>> __PU global private constants:"
  env | grep __PU_ | grep -vi _PASS | sort
  env | grep __PU_ | grep -vi _PASS | sort >>"${__pu_audit_session_file}"
  pu_log_i "PU2|08| >>>>>>>>>>>> pu_ global public variables:"
  env | grep pu_ | grep -v __pu_ | grep -vi _PASS | sort
  env | grep pu_ | grep -v __pu_ | grep -vi _PASS | sort >>"${__pu_audit_session_file}"
  pu_log_i "PU2|08| >>>>>>>>>>>> __pu_ global private variables:"
  env | grep __pu_ | grep -vi _PASS | sort
  env | grep __pu_ | grep -vi _PASS | sort >>"${__pu_audit_session_file}"
  pu_log_i "PU2|08| >>>>>>>>>>>>>>>> End Listing PU environment variables"
  unset __log_prefix
}

# Function 09 Display all environment variables and log PU variables when debug is enabled
pu_log_full_env() {
  # Shows all environment variables to console, logs only PU variables to audit log
  # Only active when __pu_debug_mode is true
  # DO NOT USE in production code!
  if [ "${__pu_debug_mode}" = "true" ]; then
    pu_log_d "PU2|09| -- Listing full environment... --"
    env | sort >&2
    pu_log_d "PU2|09| -- Listing PU environment... --"
    env | grep -i PU | sort >>"${__pu_audit_session_file}" >&2
  fi
  unset __log_prefix
}
