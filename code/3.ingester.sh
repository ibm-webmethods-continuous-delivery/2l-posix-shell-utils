#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Function 01
_pu_init_ingester() {
  # Initialize the ingester environment
  __3__cache_home="${PU_CACHE_HOME:-/tmp/pu-cache}"
  mkdir -p "${__3__cache_home}"

  pu_log_i "PU3|01 Initialized ingester with cache home: ${__3__cache_home} and online mode: ${__1__online_mode}"
}

_pu_init_ingester || exit 2

# Function 02 Ensure a public downloadable file is present in the given location and ensures checksum
pu_assure_public_file() {
  # "assure" means the file is looked up in the local location, and if not present
  # and online mode is enabled, it will be downloaded
  # otherwise, an error code is returned
  # furthermore, if a file is present or downloaded
  # and a SHA256 checksum is provided, it will be verified
  # Args:
  # $1 - online URL for download
  # $2 - full path filename
  # $3 - optional SHA256 checksum for file verification

  # Step 1 - assure the file itself
  if [ -f "${2}" ]; then
    pu_log_d "PU3|02 - File ${2} already present"
  else
    if [ "${__1__online_mode}" != "true" ]; then
      pu_log_e "PU3|02 File ${2} not found! Will not attempt download, as we are working offline!"
      return 1 # File should exist, but it does not
    fi
    pu_log_i "PU3|02 File ${2} not found in the given local position, attempting download"
    pu_log_i "PU3|02 Downloading from ${1} ..."
    curl --silent --location "${1}" --output "${2}"
    __3_02_result_curl=$?
    if [ ${__3_02_result_curl} -ne 0 ]; then
      pu_log_e "PU3|02 curl failed, code ${__3_02_result_curl}"
      return 2
    fi
    unset __3_02_result_curl
    pu_log_i "PU3|02 File ${2} downloaded successfully"
  fi

  if [ ! -f "${2}" ]; then
    pu_log_e "PU3|02 - File ${2} not found after download!"
    return 3
  fi

  __3_02_given_checksum=${3:-none}

  if [ "${__3_02_given_checksum}" != "none" ]; then
    pu_log_d "PU3|02 - Verifying SHA256 checksum for ${2}"
    __3_02_checksum=$(sha256sum "${2}" | awk '{print $1}')
    if [ "${__3_02_checksum}" != "${__3_02_given_checksum}" ]; then
      pu_log_e "PU3|02 - SHA256 checksum verification failed for ${2}"
      pu_log_e "PU3|02 - Expected: ${__3_02_given_checksum}, Found: ${__3_02_checksum}"
      unset __3_02_checksum __3_02_given_checksum
      return 4
    fi
    pu_log_i "PU3|02 - File ${2} verified"
    unset __3_02_checksum
  else
    pu_log_w "PU3|02 - File ${2} not verified"
  fi
  unset __3_02_given_checksum
  return 0
}

# Function 03 Ensure the public file is available on the local cache
pu_assure_public_framework_file() {
  # "assure" means the file is looked up in the local cache, and if not present
  # and online mode is enabled, it will be downloaded
  # otherwise, an error code is returned
  # furthermore, if a file is present or downloaded
  # and a SHA256 checksum is provided, it will be verified
  # Args:
  # $1 - server alias, interpreted as a subfolder of ${__3__cache_home}
  # $2 - server base URL
  # $3 - relative path to the server base URL becoming also relative path to __3__cache_home/${1}
  # $4 - filename, with extension and without any path token
  # $5 - optional SHA256 checksum for file verification

  pu_log_i "PU3|03 - assuring public framework file ${3}/${4} using base framework url ${2} (alias ${1})"
  mkdir -p "${__3__cache_home}/${3}"
  pu_assure_public_file "${2}/${3}" "${3}/${4}" "${5}" || return $?
}
