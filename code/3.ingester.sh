#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

if [ -z ${__pu_audit_session_file+x} ]; then
  printf "FATAL: source the file 2.audit.sh first"
  exit 201
fi

# Function 01
_pu_initIngester(){
  # Initialize the ingester environment
  __pu_cache_home="${PU_CACHE_HOME:-/tmp/pu-cache}"
  mkdir -p "${__pu_cache_home}"

  pu_log_i "PU3|01 Initialized ingester with cache home: ${__pu_cache_home} and online mode: ${__pu_online_mode}"
}

_pu_initIngester || exit 2


# Function 02 Ensure the public file is available on the local cache
pu_assurePublicFile() {
  # "assure" means the file is looked up in the local cache, and if not present 
  # and online mode is enabled, it will be downloaded
  # otherwise, an error code is returned
  # furthermore, if a file is present or downloaded
  # and a SHA256 checksum is provided, it will be verified
  # Args:
    # $1 - server alias, interpreted as a subfolder of ${__pu_cache_home}
    # $2 - server base URL
    # $3 - relative path to the server base URL becoming also relative path to __pu_cache_home/${1}
    # $4 - filename, with extension and without any path token
    # $5 - optional SHA256 checksum for file verification

  __fullFileFolder="${__pu_cache_home}/${1}/${3}"
  __fullFilePathname="${__fullFileFolder}/${4}"
  __sha256="${5:-none}"

  # Step 1 - assure the file itself
  if [ -f "${__fullFilePathname}" ]; then
    pu_log_d "PU3|02 - File ${__fullFilePathname} found in local cache"
  else
    if [ "${__pu_online_mode}" != "true" ]; then
      pu_log_e "PU3|02 File ${__fullFilePathname} not found! Will not attempt download, as we are working offline!"
      return 1 # File should exist, but it does not
    fi
    pu_log_i "PU3|02 File ${__fullFilePathname} not found in local cache, attempting download"
    pu_log_d "PU3|02 - Creating directory ${__fullFileFolder}..."
    mkdir -p "${__fullFileFolder}"
    pu_log_i "PU3|02 Downloading from ${2}/${3}/${4} ..."
    curl --silent --location "${2}/${3}/${4}" --output "${__fullFilePathname}"
    __result_curl=$?
    if [ ${__result_curl} -ne 0 ]; then
      pu_log_e "PU3|02 curl failed, code ${__result_curl}"
      unset __log_prefix __fullFileFolder __fullFilePathname __result_curl __sha256
      return 2
    fi
    unset __result_curl
    pu_log_i "PU3|02 File ${__fullFilePathname} downloaded successfully"
  fi

  if [ ! -f "${__fullFilePathname}" ]; then
    pu_log_e "PU3|02 - File ${__fullFilePathname} not found after download!"
    unset __log_prefix __fullFileFolder __fullFilePathname __sha256
    return 3
  fi

  if [ "${__sha256}" != "none" ]; then
    pu_log_d "PU3|02 - Verifying SHA256 checksum for ${__fullFilePathname}"
    __checksum=$(sha256sum "${__fullFilePathname}" | awk '{print $1}')
    if [ "${__checksum}" != "${__sha256}" ]; then
      pu_log_e "PU3|02 - SHA256 checksum verification failed for ${__fullFilePathname}"
      pu_log_e "PU3|02 - Expected: ${__sha256}, Found: ${__checksum}"
      unset __log_prefix __fullFileFolder __fullFilePathname __sha256
      return 4
    fi
    pu_log_i "PU3|02 - File ${__fullFilePathname} verified"
  else
    pu_log_w "PU3|02 - File ${__fullFilePathname} not verified"
  fi
  unset __log_prefix __fullFileFolder __fullFilePathname __sha256
  return 0
}