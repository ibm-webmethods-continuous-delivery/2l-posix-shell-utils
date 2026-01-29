#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# This module offers audited log and execution functions
# with the purpose of tracing scripted activity both
# for attended and unattended jobs

# Function 01 Initialize audit session with directory structure and settings
pu_audit_init_session() {
  # Sets up debug environment variable, audit base directory, session timestamp, and session directory
  # Also initializes colored output setting from environment
  __2__audit_base_dir="${PU_AUDIT_BASE_DIR:-/tmp/pu-default-audit}"
  __2__session_timestamp="${PU_SESSION_TIMESTAMP:-$(date +%y-%m-%dT%H.%M.%S)}"
  __2__audit_session_dir="${__2__audit_base_dir}/${__2__session_timestamp}"
  mkdir -p "${__2__audit_session_dir}"
  __2__audit_session_file="${__2__audit_session_dir}/session.log"
  # Color codes for console output
  __1__clr_reset='\033[0m'

  # Log session initialization
  pu_log_i "PU2|01| ==============================================================="
  pu_log_i "PU2|01| A new session had been initialized"
  pu_log_i "PU2|01| Current timestamp is   : $(date +%y-%m-%dT%H.%M.%S)"
  pu_log_i "PU2|01| Current session file is: ${__2__audit_session_file}"
  pu_log_i "PU2|01| =========> Received audit session variables:"
  pu_log_i "PU2|01| PU_AUDIT_BASE_DIR=${PU_AUDIT_BASE_DIR}"
  pu_log_i "PU2|01| PU_SESSION_TIMESTAMP=${PU_SESSION_TIMESTAMP}"
  pu_log_i "PU2|01| =========> Effective audit session variables:"
  pu_log_i "PU2|01| __2__audit_base_dir=${__2__audit_base_dir}"
  pu_log_i "PU2|01| __2__audit_session_dir=${__2__audit_session_dir}"
  pu_log_i "PU2|01| __1__colored_mode=${__1__colored_mode}"
  pu_log_i "PU2|01| __1__debug_mode=${__1__debug_mode}"
  pu_log_i "PU2|01| __2__session_timestamp=${__2__session_timestamp}"
  pu_log_i "PU2|01| ==============================================================="

  return $?
}

# Function 02 Execute command with controlled output redirection to audit files
pu_audited_exec() {
  # Args:
  #   $1 - command to execute in a controlled manner
  #   $2 - tag for trace files
  __2_02_current_epoch="$(date +%s)"
  __2_02_file_name="${__2__audit_session_dir}/cExec_${__2_02_current_epoch}_${2}"

  eval "${1}" >"${__2_02_file_name}.out" 2>"${__2_02_file_name}.err"
  __2_02_eval_res=$?
  if [ ${__2_02_eval_res} -ne 0 ]; then
      pu_log_e "PU2|02| Command having tag ${2} failed with code: ${__2_02_eval_res}"
      pu_log_d "PU2|02| Command output: ${__2_02_file_name}.out"
      pu_log_d "PU2|02| Command error: ${__2_02_file_name}.err"
      unset __2_02_current_epoch __2_02_file_name
      return 1
  fi
  unset __2_02_current_epoch __2_02_file_name
  return 0
}

# Function 03 Generate consistent timestamps with epoch time base for audit logging
_pu_get_timestamp() {
  # Uses epoch time as base for potential sub-second precision in future
  # Sets __2_03_current_epoch as side effect for advanced timing features
  __2_03_current_timestamp="$(date +%y\ %m\ %dT%H%M%S)"
  __2_03_cmd="printf '%s%X%s' ${__2_03_current_timestamp}"
  eval "${__2_03_cmd}"
  unset __2_03_current_timestamp __2_03_cmd
}

# Function 04 audit log INFO level messages
pu_log_i() {
  # Args:
  #   $1 - Message to log
  __2_04_msg=${1:-no\ message\?}
  __2_04_time=$(date -u +%H%M%S)

  # Decision: Info messages are never colored, color distinguish the other types
  echo "${__2_04_time}I ${__2_04_msg}" >&2
  echo "${__2_04_time}I ${__2_04_msg}" >>"${__2__audit_session_file}"
  unset __2_04_msg __2_04_time
}

# Function 05 Log warning level messages to audit session
pu_log_w() {
  # Args:
  #   $1 - Message to log
  __2_05_msg=${1:-no\ message\?}
  __2_05_time=$(date -u +%H%M%S)
  if [ "${__1__colored_mode}" = "true" ]; then
    __2_05_clr='\033[0;33m' # Yellow
    printf "%s%bW%b %b%s%b\n" \
      "${__2_05_time}" "${__2_05_clr}" "${__1__clr_reset}" "${__2_05_clr}" "${__2_05_msg}" "${__1__clr_reset}" >&2
    unset __2_05_clr
  else
    echo "${__2_05_time}W ${__2_05_msg}" >&2
  fi
  echo "${__2_05_time}W ${__2_05_msg}" >>"${__2__audit_session_file}"
  unset __2_05_msg __2_05_time
}

# Function 06 Log error level messages to audit session
pu_log_e() {
  # Args:
  #   $1 - Message to log
  __2_06_msg=${1:-no\ message\?}
  __2_06_time=$(date -u +%H%M%S)
  if [ "${__1__colored_mode}" = "true" ]; then
    __2_06_clr='\033[0;31m' # Red
    printf "%s%bE%b %b%s%b\n" \
      "${__2_06_time}" "${__2_06_clr}" "${__1__clr_reset}" "${__2_06_clr}" "${__2_06_msg}" "${__1__clr_reset}" >&2
    unset __2_06_clr
  else
    echo "${__2_06_time}E ${__2_06_msg}" >&2
  fi
  echo "${__2_06_time}E ${__2_06_msg}" >>"${__2__audit_session_file}"
  unset __2_06_msg __2_06_time
}

# Function 07 Log debug level messages to audit session when debug is enabled
pu_log_d() {
  # Args:
  #   $1 - Message to log
  # Only logs when __1__debug_mode is true
  if [ "${__1__debug_mode}" = "true" ]; then
    __2_07_msg=${1:-no\ message\?}
    __2_07_time=$(date -u +%H%M%S)
    if [ "${__1__colored_mode}" = "true" ]; then
      __2_07_clr='\033[0;36m' # Cyan
      printf "%s%bD%b %b%s%b\n" \
        "${__2_07_time}" "${__2_07_clr}" "${__1__clr_reset}" "${__2_07_clr}" "${__2_07_msg}" "${__1__clr_reset}" >&2
      unset __2_07_clr
    else
      echo "${__2_07_time}D ${__2_07_msg}" >&2
    fi
    echo "${__2_07_time}D ${__2_07_msg}" >>"${__2__audit_session_file}"
    unset __2_07_msg __2_07_time
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
  env | grep PU_ | grep -vi _PASS | grep -v _PU_ | sort >>"${__2__audit_session_file}"
  pu_log_i "PU2|08| >>>>>>>>>>>> __PU global private constants:"
  env | grep __PU_ | grep -vi _PASS | sort
  env | grep __PU_ | grep -vi _PASS | sort >>"${__2__audit_session_file}"
  pu_log_i "PU2|08| >>>>>>>>>>>> pu_ global public variables:"
  env | grep pu_ | grep -v __pu_ | grep -vi _PASS | sort
  env | grep pu_ | grep -v __pu_ | grep -vi _PASS | sort >>"${__2__audit_session_file}"
  pu_log_i "PU2|08| >>>>>>>>>>>> __pu_ global private variables:"
  env | grep __pu_ | grep -vi _PASS | sort
  env | grep __pu_ | grep -vi _PASS | sort >>"${__2__audit_session_file}"
  pu_log_i "PU2|08| >>>>>>>>>>>>>>>> End Listing PU environment variables"
}

# Function 09 Display all environment variables and log PU variables when debug is enabled
pu_log_full_env() {
  # Shows all environment variables to console, logs only PU variables to audit log
  # Only active when __1__debug_mode is true
  # DO NOT USE in production code!
  if [ "${__1__debug_mode}" = "true" ]; then
    pu_log_d "PU2|09| -- Listing full environment... --"
    env | sort >&2
    pu_log_d "PU2|09| -- Listing PU environment... --"
    env | grep -i PU | sort >>"${__2__audit_session_file}" >&2
  fi
}
