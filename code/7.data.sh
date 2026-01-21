#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# This module offers data format conversion utilities
# for POSIX-compatible shell scripts

# Function 01 Convert CSV string to lines
pu_csv_to_lines() {
  # Convert a comma-separated values string to separate lines
  #
  # Args:
  #   $1 - CSV string to convert
  #   $2 - OPTIONAL: delimiter character (default: ",")
  #
  # Output: Each value on a separate line to stdout
  #
  # Example:
  #   pu_csv_to_lines "apple,banana,cherry"
  #   # Output:
  #   # apple
  #   # banana
  #   # cherry
  #
  #   pu_csv_to_lines "apple|banana|cherry" "|"
  #   # Output with custom delimiter:
  #   # apple
  #   # banana
  #   # cherry

  if [ -z "$1" ]; then
    pu_log_e "PU7|01|pu_csv_to_lines requires a CSV string argument"
    return 1
  fi

  __7_01_csv_string="$1"
  __7_01_delimiter="${2:-,}"

  echo "${__7_01_csv_string}" | tr "${__7_01_delimiter}" '\n'

  unset __7_01_csv_string __7_01_delimiter
  return 0
}

# Function 02 Convert lines file to CSV string
pu_lines_to_csv() {
  # Convert a file containing lines to a comma-separated values string
  #
  # Args:
  #   $1 - path to file containing lines
  #   $2 - OPTIONAL: delimiter character (default: ",")
  #
  # Output: CSV string to stdout
  #
  # Returns:
  #   0 on success
  #   1 if file not found
  #
  # Example:
  #   # Given file.txt with content:
  #   # apple
  #   # banana
  #   # cherry
  #
  #   pu_lines_to_csv "file.txt"
  #   # Output: apple,banana,cherry

  if [ -z "$1" ]; then
    pu_log_e "PU7|02|pu_lines_to_csv requires a file path argument"
    return 1
  fi

  if [ ! -f "$1" ]; then
    pu_log_e "PU7|02|File not found: \"$1\""
    return 1
  fi

  __7_02_file_path="$1"
  __7_02_delimiter="${2:-,}"
  __7_02_first_line=1

  while read -r __7_02_line; do
    if [ ${__7_02_first_line} -eq 1 ]; then
      __7_02_first_line=0
    else
      printf '%s' "${__7_02_delimiter}"
    fi
    printf '%s' "${__7_02_line}"
  done <"${__7_02_file_path}"

  unset __7_02_file_path __7_02_delimiter __7_02_first_line __7_02_line
  return 0
}

# Function 03 Parse YAML file to environment variables
pu_parse_yaml() {
  # Parse a YAML file and convert it to shell export statements
  # This function handles simple YAML structures (key-value pairs)
  #
  # Args:
  #   $1 - path to YAML file
  #   $2 - OPTIONAL: prefix for environment variables (default: none)
  #
  # Output: Shell export statements to stdout
  #
  # Returns:
  #   0 on success
  #   1 if file not found
  #
  # Note: This is a simplified YAML parser for basic key-value structures
  # It may not handle complex YAML features like arrays, multi-line strings, etc.
  #
  # Credits: Based on https://gist.github.com/pkuczynski/8665367
  #
  # Example:
  #   # Given config.yaml:
  #   # database:
  #   #   host: localhost
  #   #   port: 5432
  #
  #   eval $(pu_parse_yaml "config.yaml" "APP_")
  #   # Creates: APP_database_host="localhost"
  #   #          APP_database_port="5432"

  if [ -z "$1" ]; then
    pu_log_e "PU7|03|pu_parse_yaml requires a file path argument"
    return 1
  fi

  if [ ! -f "$1" ]; then
    pu_log_e "PU7|03|File not found: \"$1\""
    return 1
  fi

  __7_03_yaml_file="$1"
  __7_03_prefix="$2"
  __7_03_s='[[:space:]]*'
  __7_03_w='[a-zA-Z0-9_]*'
  __7_03_fs=$(echo @ | tr @ '\034')

  # shellcheck disable=SC2086
  sed "h;s/^[^:]*//;x;s/:.*$//;y/-/_/;G;s/\n//" ${__7_03_yaml_file} |
    sed -ne "s|^\(${__7_03_s}\)\(${__7_03_w}\)${__7_03_s}:${__7_03_s}\"\(.*\)\"${__7_03_s}\$|\1${__7_03_fs}\2${__7_03_fs}\3|p" \
      -e "s|^\(${__7_03_s}\)\(${__7_03_w}\)${__7_03_s}:${__7_03_s}\(.*\)${__7_03_s}\$|\1${__7_03_fs}\2${__7_03_fs}\3|p" |
    awk -F"${__7_03_fs}" '{
    indent = length($1)/2;
    vname[indent] = $2;

    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
        vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
        printf("export %s%s%s=\"%s\"\n", "'"${__7_03_prefix}"'",vn, $2, $3);
    }
  }'

  unset __7_03_yaml_file __7_03_prefix __7_03_s __7_03_w __7_03_fs
  return 0
}

# Function 04 Load environment variables from YAML file
pu_load_env_from_yaml() {
  # Load environment variables from a YAML file with a given prefix
  # This is a convenience wrapper around pu_parse_yaml that evaluates the output
  #
  # Args:
  #   $1 - path to YAML file
  #   $2 - OPTIONAL: prefix for environment variables (default: none)
  #
  # Returns:
  #   0 on success
  #   1 if file not found or parsing failed
  #
  # Example:
  #   pu_load_env_from_yaml "config.yaml" "APP_"
  #   echo $APP_database_host  # Access loaded variable

  if [ -z "$1" ]; then
    pu_log_e "PU7|04|pu_load_env_from_yaml requires a file path argument"
    return 1
  fi

  if [ ! -f "$1" ]; then
    pu_log_e "PU7|04|File not found: \"$1\""
    return 1
  fi

  __7_04_yaml_file="$1"
  __7_04_prefix="$2"

  # shellcheck disable=SC2046
  eval $(pu_parse_yaml "${__7_04_yaml_file}" "${__7_04_prefix}")
  __7_04_result=$?

  if [ ${__7_04_result} -ne 0 ]; then
    pu_log_e "PU7|04|Failed to load environment from YAML file: ${__7_04_yaml_file}"
    unset __7_04_yaml_file __7_04_prefix __7_04_result
    return 1
  fi

  pu_log_i "PU7|04|Successfully loaded environment variables from: ${__7_04_yaml_file}"
  unset __7_04_yaml_file __7_04_prefix __7_04_result
  return 0
}

pu_log_i "PU7|Data format utilities module loaded successfully"
