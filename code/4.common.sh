#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

if [ -z ${__2__audit_session_file+x} ]; then
  printf "FATAL: source the file 2.audit.sh first"
  exit 201
fi

pu_read_secret_from_user() {

  # Parameters:
  # ${1} a mnemonic label to display to the user "Please input ${1}"

  # code inspired from https://stackoverflow.com/questions/3980668/how-to-get-a-password-from-a-shell-script-without-echoing

  # User MUST take the value from $secret immediately after and unset the variable
  stty -echo
  secret="0"
  __4_01_s1="a"
  __4_01_s2="a"
  while [ "${secret}" = "0" ]; do
    printf "Please input %s: " "${1}"
    read -r __4_01_s1
    printf "\n"
    printf "Please input %s again: " "${1}"
    read -r __4_01_s2
    printf "\n"
    if [ "${__4_01_s1}" = "${__4_01_s2}" ]; then
      secret=${__4_01_s1}
    else
      echo "Inputs do not match, please retry!"
    fi
    unset __4_01_s1 __4_01_s2
  done
  stty echo
}

# Function 02 Log environment variables with password filtering
pu_log_env_filtered() {
  # Display and log environment variables with sensitive data filtered out
  # Filters out variables containing PASS, password, or dbpass (case-insensitive)
  # Only active when __1__debug_mode is true
  #
  # Args:
  #   $1 - OPTIONAL: variable prefix to filter (default: "PU")
  #
  # Example:
  #   pu_log_env_filtered "APP"
  #   # Shows APP_* variables, excluding passwords

  if [ "${__1__debug_mode}" != "true" ]; then
    return 0
  fi

  __4_02_var_prefix="${1:-PU}"

  pu_log_d "PU4|02|Dumping ${__4_02_var_prefix}* environment variables (passwords filtered)"

  if [ "${WMUI_SUPPRESS_STDOUT:-0}" -eq 0 ]; then
    env | grep "${__4_02_var_prefix}_" | grep -v PASS | grep -vi password | grep -vi dbpass | sort >&2
  fi

  env | grep "${__4_02_var_prefix}_" | grep -v PASS | grep -vi password | grep -vi dbpass | sort >>"${__2__audit_session_file}"

  unset __4_02_var_prefix
  return 0
}

# Function 03 Suspend execution for debugging purposes
pu_debug_suspend() {
  # Suspend script execution indefinitely for debugging
  # Only active when __1__debug_mode is true
  # Useful for keeping containers alive or pausing execution
  #
  # To resume: kill the process or container
  #
  # Example:
  #   pu_debug_suspend
  #   # Script will hang here if debug mode is enabled

  if [ "${__1__debug_mode}" = "true" ]; then
    pu_log_d "PU4|03|Suspending execution for debugging (tail -f /dev/null)"
    tail -f /dev/null
  fi
}

pu_log_i "PU4|Common utilities module loaded successfully"
