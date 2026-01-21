#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

## Quick start init file for the current utilities

# Function 01
_pu_init_error(){
  # This is intended to be private to the current file. use pu_log_? for general auditing functions after sourcing audit.sh
  # Parameters
  # $1 - error message
  if [ "${__1__colored_mode}" = "true" ]; then
    __1_01_red='\033[0;31m' # Red
    printf "PU1|%bERROR: %s%b\n" "${__1_01_red}" "${1}" "${__1__clr_reset}" >&2
    unset __1_01_red
  else
    echo "PU1|ERROR: ${1}" >&2
  fi
}

# Function 02
_pu_init_info(){
  # This is intended to be private to the current file. use pu_log_? for general auditing functions after sourcing audit.sh
  # Parameters
  # $1 - info message
  if [ "${__1__colored_mode}" = "true" ]; then
    __1_02_cyan='\033[0;36m' # Cyan
    printf "PU1|%bINFO: %s%b\n" "${__1_02_cyan}" "${1}" "${__1__clr_reset}" >&2
    unset __1_02_cyan
  else
    echo "PU1|INFO: ${1}" >&2
  fi
}

# Function 03
pu_init_hunt_for_pu_file() {
  # Parameters - hunt for PU file
  # $1 - relative Path to PU_HOME
  # $2 - filename
  if [ ! -f "${PU_HOME}/${1}/${2}" ]; then
    if [ "${__1__online_mode}" != "true" ]; then
      _pu_init_error "03|File ${PU_HOME}/${1}/${2} not found! Will not attempt download, as we are working offline!"
      return 1 # File should exist, but it does not
    fi
    __1_03_source_tag=${PU_SOURCE_TAG:-v0.0.8}
    # if tag is used, value is tag/$tag
    __1_03_home_url=${PU_HOME_URL:-https://raw.githubusercontent.com/ibm-webmethods-continuous-delivery/2l-posix-shell-utils/refs/tags/${__1_03_source_tag}}
    _pu_init_info "03|File ${PU_HOME}/${1}/${2} not found in local cache, attempting download.."
    mkdir -p "${PU_HOME}/${1}"
    _pu_init_info "03|Downloading from ${__1_03_home_url}/${1}/${2} ..."
    if ! curl "${__1_03_home_url}/${1}/${2}" --silent -o "${PU_HOME}/${1}/${2}" ; then
      _pu_init_error "03|curl failed, code $?"
      return 2
    fi
    _pu_init_info "03|File ${PU_HOME}/${1}/${2} downloaded successfully"
    unset __1_03_source_tag __1_03_home_url
  fi
}

# Function 04
_pu_init(){
  # Rule: you MUST have at least this file in the folder ${PU_HOME}/code/init.sh, i.e. ${PU_HOME} MUST be correctly initialized.

  if [ ! -f "${PU_HOME}/code/1.init.sh" ]; then
    _pu_init_error "04|${PU_HOME}/code/1.init.sh file not found!"
    exit 201 # serious enough
  fi

  # Assurance of framework variables and work modes
  __1__clr_reset='\033[0m'

  # We may work online or offline, online means we can do"hunt" for files when needed. "true" string value for true, anything else for false
  __1__online_mode="${PU_ONLINE_MODE:-true}"

  # We may work with user attendance or not.
  __1__attended_mode="${PU_ATTENDED_MODE:-true}"

  # We may work with debugging for more verbose output.
  __1__debug_mode="${PU_DEBUG_MODE:-true}"

  # We may work with colored output for more visible output.
  __1__colored_mode="${PU_COLORED_MODE:-true}"

  # We may automatically assure ingester too
  __1__init_ingester=${PU_INIT_INGESTER:-false}

  # We may automatically assure the commons too
  __1__init_common=${PU_INIT_COMMON:-false}

  # We may automatically assure network utilities
  __1__init_network=${PU_INIT_NETWORK:-false}

  # We may automatically assure string utilities
  __1__init_string=${PU_INIT_STRING:-false}

  # We may automatically assure data format utilities
  __1__init_data=${PU_INIT_DATA:-false}


  # We may also directly hunt for our own files at init time.
  if [ "${__1__online_mode}" = "true" ]; then
    if ! pu_init_hunt_for_pu_file "code" "2.audit.sh" ; then
      _pu_init_error "04|Cannot assure 2.audit.sh source file! Code $?"
      exit 202 #this one is mandatory, fail if cannot obtain
    fi
    if [ "${__1__init_ingester}" = "true" ]; then
      if ! pu_init_hunt_for_pu_file "code" "3.ingester.sh" ; then
        _pu_init_error "04|Cannot assure 3.ingester.sh source file! Code $?"
      fi
    fi
    if [ "${__1__init_common}" = "true" ]; then
      if ! pu_init_hunt_for_pu_file "code" "4.common.sh" ; then
        _pu_init_error "04|Cannot assure 4.common.sh source file! Code $?"
      fi
    fi
    if [ "${__1__init_network}" = "true" ]; then
      if ! pu_init_hunt_for_pu_file "code" "5.network.sh" ; then
        _pu_init_error "04|Cannot assure 5.network.sh source file! Code $?"
      fi
    fi
    if [ "${__1__init_string}" = "true" ]; then
      if ! pu_init_hunt_for_pu_file "code" "6.string.sh" ; then
        _pu_init_error "04|Cannot assure 6.string.sh source file! Code $?"
      fi
    fi
    if [ "${__1__init_data}" = "true" ]; then
      if ! pu_init_hunt_for_pu_file "code" "7.data.sh" ; then
        _pu_init_error "04|Cannot assure 7.data.sh source file! Code $?"
      fi
    fi
  fi

  # Source the audit module (mandatory)
  . "${PU_HOME}/code/2.audit.sh"

  # Source optional modules based on flags
  if [ "${__1__init_ingester}" = "true" ]; then
    . "${PU_HOME}/code/3.ingester.sh"
  fi
  if [ "${__1__init_common}" = "true" ]; then
    . "${PU_HOME}/code/4.common.sh"
  fi
  if [ "${__1__init_network}" = "true" ]; then
    . "${PU_HOME}/code/5.network.sh"
  fi
  if [ "${__1__init_string}" = "true" ]; then
    . "${PU_HOME}/code/6.string.sh"
  fi
  if [ "${__1__init_data}" = "true" ]; then
    . "${PU_HOME}/code/7.data.sh"
  fi
}

# Function 05
pu_msg_ok_utf8(){
  __1_05_green='\033[0;32m'
  printf "PU1|%b✅ ${1}%b\n" "${__1_05_green}" "${__1__clr_reset}"
  unset __1_05_green
}

# Function 06
pu_msg_fail_utf8(){
  __1_06_red='\033[0;31m'
  printf "PU1|%b❌ ${1}%b\n" "${__1_06_red}" "${__1__clr_reset}"
  unset __1_06_red
}

# Function 07
pu_msg_info_utf8(){
  __1_07_blue='\033[0;34m'
  printf "PU1|%bℹ️  ${1}%b\n" "${__1_07_blue}" "${__1__clr_reset}"
  unset __1_07_blue
}

# Function 08
pu_msg_warning_utf8(){
  __1_08_yellow='\033[1;33m'
  printf "PU1|%b⚠️  ${1}%b\n" "${__1_08_yellow}" "${__1__clr_reset}"
  unset __1_08_yellow
}

_pu_init || exit $?
