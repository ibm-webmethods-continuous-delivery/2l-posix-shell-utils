#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

## Quick start init file for the current utilities

# Function 01
_pu_init_error(){
  # This is intended to be private to the current file. use pu_log_? for general auditing functions after sourcing audit.sh
  # Parameters
  # $1 - error message
  if [ "${__pu_colored_mode}" = "true" ]; then
    _pu_init_red='\033[0;31m' # Red
    printf "%b%s%b\n" "${_pu_init_red}" "PU1|ERROR: ${1}" "${__pu_clr_reset}" >&2
    unset _pu_init_red
  else
    echo "PU1|ERROR: ${1}" >&2
  fi
}

# Function 02
_pu_init_info(){
  # This is intended to be private to the current file. use pu_log_? for general auditing functions after sourcing audit.sh
  # Parameters
  # $1 - info message
  if [ "${__pu_colored_mode}" = "true" ]; then
    _pu_init_cyan='\033[0;36m' # Cyan
    printf "%b%s%b\n" "${_pu_init_cyan}" "PU1|INFO: ${1}" "${__pu_clr_reset}" >&2
    unset _pu_init_cyan
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
    if [ "${__pu_online_mode}" != "true" ]; then
      _pu_init_error "03|File ${PU_HOME}/${1}/${2} not found! Will not attempt download, as we are working offline!"
      return 1 # File should exist, but it does not
    fi
    __pu_source_branch=${PU_SOURCE_BRANCH:-main}
    # if tag is used, value is tag/$tag
    __pu_home_url=${PU_HOME_URL:-https://raw.githubusercontent.com/ibm-webmethods-continuous-delivery/2l-posix-shell-utils/refs/${__pu_source_branch}}
    _pu_init_info "03|File ${PU_HOME}/${1}/${2} not found in local cache, attempting download.."
    mkdir -p "${PU_HOME}/${1}"
    _pu_init_info "03|Downloading from ${__pu_home_url}/${1}/${2} ..."
    if ! curl "${__pu_home_url}/${1}/${2}" --silent -o "${PU_HOME}/${1}/${2}" ; then
      _pu_init_error "03|curl failed, code $?"
      return 2
    fi
    _pu_init_info "03|File ${PU_HOME}/${1}/${2} downloaded successfully"
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
  __pu_clr_reset='\033[0m'

  # We may work online or offline, online means we can do"hunt" for files when needed. "true" string value for true, anything else for false
  __pu_online_mode="${PU_ONLINE_MODE:-true}"

  # We may work with user attendance or not. 
  __pu_attended_mode="${PU_ATTENDED_MODE:-true}"

  # We may work with debugging for more verbose output. 
  __pu_debug_mode="${PU_DEBUG_MODE:-true}"

  # We may work with colored output for more visible output. 
  __pu_colored_mode="${PU_COLORED_MODE:-true}"

  # We may automatically assure ingester too
  __pu_init_ingester=${PU_INIT_INGESTER:-false}

  # We may automatically assure the commons too
  __pu_init_common=${PU_INIT_COMMON:-false}


  # We may also directly hunt for our own files at init time.
  if [ "${__pu_online_mode}" = "true" ]; then
    if ! pu_init_hunt_for_pu_file "code" "2.audit.sh" ; then
      _pu_init_error "04|Cannot assure 2.audit.sh source file! Code $?"
      exit 202 #this one is mandatory, fail if cannot obtain
    fi
    if [ "${__pu_init_ingester}" = "true" ]; then
      if ! pu_init_hunt_for_pu_file "code" "3.ingester.sh" ; then
        _pu_init_error "04|Cannot assure 3.ingester.sh source file! Code $?"
      fi
    fi
    if [ "${__pu_init_common}" = "true" ]; then
      if ! pu_init_hunt_for_pu_file "code" "4.common.sh" ; then
        _pu_init_error "04|Cannot assure 4.common.sh source file! Code $?"
      fi
    fi
  fi
}

_pu_init || exit $?
# 