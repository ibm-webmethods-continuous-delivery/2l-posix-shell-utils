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

# Function 02 Ensure the public file is available on the local cache
pu_assure_public_file() {
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

  __3_02_full_file_folder="${__3__cache_home}/${1}/${3}"
  __3_02_full_file_pathname="${__3_02_full_file_folder}/${4}"
  __3_02_sha256="${5:-none}"

  # Step 1 - assure the file itself
  if [ -f "${__3_02_full_file_pathname}" ]; then
    pu_log_d "PU3|02 - File ${__3_02_full_file_pathname} found in local cache"
  else
    if [ "${__1__online_mode}" != "true" ]; then
      pu_log_e "PU3|02 File ${__3_02_full_file_pathname} not found! Will not attempt download, as we are working offline!"
      unset __3_02_full_file_folder __3_02_full_file_pathname __3_02_sha256
      return 1 # File should exist, but it does not
    fi
    pu_log_i "PU3|02 File ${__3_02_full_file_pathname} not found in local cache, attempting download"
    pu_log_d "PU3|02 - Creating directory ${__3_02_full_file_folder}..."
    mkdir -p "${__3_02_full_file_folder}"
    pu_log_i "PU3|02 Downloading from ${2}/${3}/${4} ..."
    curl --silent --location "${2}/${3}/${4}" --output "${__3_02_full_file_pathname}"
    __3_02_result_curl=$?
    if [ ${__3_02_result_curl} -ne 0 ]; then
      pu_log_e "PU3|02 curl failed, code ${__3_02_result_curl}"
      unset __3_02_full_file_folder __3_02_full_file_pathname __3_02_result_curl __3_02_sha256
      return 2
    fi
    unset __3_02_result_curl
    pu_log_i "PU3|02 File ${__3_02_full_file_pathname} downloaded successfully"
  fi

  if [ ! -f "${__3_02_full_file_pathname}" ]; then
    pu_log_e "PU3|02 - File ${__3_02_full_file_pathname} not found after download!"
    unset __3_02_full_file_folder __3_02_full_file_pathname __3_02_sha256
    return 3
  fi

  if [ "${__3_02_sha256}" != "none" ]; then
    pu_log_d "PU3|02 - Verifying SHA256 checksum for ${__3_02_full_file_pathname}"
    __3_02_checksum=$(sha256sum "${__3_02_full_file_pathname}" | awk '{print $1}')
    if [ "${__3_02_checksum}" != "${__3_02_sha256}" ]; then
      pu_log_e "PU3|02 - SHA256 checksum verification failed for ${__3_02_full_file_pathname}"
      pu_log_e "PU3|02 - Expected: ${__3_02_sha256}, Found: ${__3_02_checksum}"
      unset __3_02_full_file_folder __3_02_full_file_pathname __3_02_sha256 __3_02_checksum
      return 4
    fi
    pu_log_i "PU3|02 - File ${__3_02_full_file_pathname} verified"
    unset __3_02_checksum
  else
    pu_log_w "PU3|02 - File ${__3_02_full_file_pathname} not verified"
  fi
  unset __3_02_full_file_folder __3_02_full_file_pathname __3_02_sha256
  return 0
}
