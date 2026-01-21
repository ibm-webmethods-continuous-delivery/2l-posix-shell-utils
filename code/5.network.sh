#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# This module offers network connectivity and port checking utilities
# for POSIX-compatible shell scripts

# Function 01 Check if a port is reachable on a host
pu_port_is_reachable() {
  # Check if a specific port is reachable on a given host
  # Uses nc (netcat) if available, otherwise falls back to /dev/tcp
  #
  # Args:
  #   $1 - hostname or IP address
  #   $2 - port number
  #
  # Returns:
  #   0 if port is reachable
  #   1 if port is not reachable
  #
  # Example:
  #   if pu_port_is_reachable "localhost" "8080"; then
  #     pu_log_i "Port 8080 is open"
  #   fi

  if [ -z "$1" ] || [ -z "$2" ]; then
    pu_log_e "PU5|01|pu_port_is_reachable requires hostname and port arguments"
    return 2
  fi

  __5_01_host="$1"
  __5_01_port="$2"

  if [ -f /usr/bin/nc ]; then
    # Use netcat if available (e.g., Alpine Linux)
    # shellcheck disable=SC2086
    nc -z ${__5_01_host} ${__5_01_port} >/dev/null 2>&1
    __5_01_result=$?
  else
    # Fall back to /dev/tcp (e.g., bash on CentOS/RHEL)
    # shellcheck disable=SC3025,SC2086
    (echo >/dev/tcp/${__5_01_host}/${__5_01_port}) >/dev/null 2>&1
    __5_01_result=$?
  fi

  unset __5_01_host __5_01_port
  return ${__5_01_result}
}

# Function 02 Wait for a port to become reachable with retry logic
pu_wait_for_port() {
  # Wait for a port to become reachable on a host with configurable retry logic
  # Useful for waiting for services to start up
  #
  # Args:
  #   $1 - hostname or IP address
  #   $2 - port number
  #   $3 - OPTIONAL: maximum number of retries (default: 30)
  #   $4 - OPTIONAL: sleep time between retries in seconds (default: 5)
  #
  # Returns:
  #   0 if port becomes reachable within retry limit
  #   1 if port is not reachable after maximum retries
  #
  # Example:
  #   # Wait up to 2 minutes (24 retries * 5 seconds)
  #   if pu_wait_for_port "database" "5432" 24 5; then
  #     pu_log_i "Database is ready"
  #   else
  #     pu_log_e "Database failed to start"
  #   fi

  if [ -z "$1" ] || [ -z "$2" ]; then
    pu_log_e "PU5|02|pu_wait_for_port requires hostname and port arguments"
    return 2
  fi

  __5_02_host="$1"
  __5_02_port="$2"
  __5_02_max_count="${3:-30}"
  __5_02_sleep_seconds="${4:-5}"
  __5_02_count=0

  pu_log_i "PU5|02|Waiting for port ${__5_02_port} on host ${__5_02_host} (max retries: ${__5_02_max_count}, interval: ${__5_02_sleep_seconds}s)"

  until pu_port_is_reachable "${__5_02_host}" "${__5_02_port}"; do
    pu_log_d "PU5|02|Port ${__5_02_port} on host ${__5_02_host} not yet reachable (attempt $((${__5_02_count} + 1))/${__5_02_max_count})"
    sleep "${__5_02_sleep_seconds}"
    __5_02_count=$((__5_02_count + 1))

    if [ "${__5_02_count}" -ge "${__5_02_max_count}" ]; then
      pu_log_w "PU5|02|Port ${__5_02_port} on host ${__5_02_host} is not reachable after ${__5_02_max_count} retries"
      unset __5_02_host __5_02_port __5_02_max_count __5_02_sleep_seconds __5_02_count
      return 1
    fi
  done

  pu_log_i "PU5|02|Port ${__5_02_port} on host ${__5_02_host} is now reachable (after ${__5_02_count} retries)"
  unset __5_02_host __5_02_port __5_02_max_count __5_02_sleep_seconds __5_02_count
  return 0
}

pu_log_i "PU5|Network utilities module loaded successfully"
