#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# This module offers string manipulation and encoding utilities
# for POSIX-compatible shell scripts

# Function 01 URL encode a string via pipe (internal helper)
pu_urlencode_pipe() {
  # URL encode input from stdin, character by character
  # This is a POSIX-portable implementation using od and tr
  #
  # Input: stdin (piped input)
  # Output: URL-encoded string to stdout
  #
  # Note: This is typically used internally by pu_urlencode()
  #
  # Example:
  #   echo "hello world" | pu_urlencode_pipe
  #   # Output: hello%20world

  __6_01_lang=C
  __6_01_c=""
  while IFS= read -r __6_01_c; do
    # shellcheck disable=SC2059
    case $__6_01_c in [a-zA-Z0-9.~_-])
      printf "$__6_01_c"
      continue
      ;;
    esac
    # shellcheck disable=SC2059
    printf "$__6_01_c" | od -An -tx1 | tr ' ' % | tr -d '\n'
  done <<EOF
$(fold -w1)
EOF
  echo
  unset __6_01_lang __6_01_c
}

# Function 02 URL encode a string
pu_urlencode() {
  # URL encode a string for safe use in URLs
  # Encodes special characters to percent-encoded format
  #
  # Args:
  #   $* - String to encode (all arguments concatenated)
  #
  # Output: URL-encoded string to stdout
  #
  # Example:
  #   encoded=$(pu_urlencode "hello world & special chars!")
  #   echo "$encoded"
  #   # Output: hello%20world%20%26%20special%20chars%21

  # shellcheck disable=SC2059
  printf "$*" | pu_urlencode_pipe
}

# Function 03 POSIX-compatible string substitution
pu_str_substitute() {
  # Substitute characters in a string using POSIX tr command
  # Works character-by-character, not with substrings
  #
  # Args:
  #   $1 - original string
  #   $2 - character set to substitute (from)
  #   $3 - replacement character set (to)
  #
  # Output: Transformed string to stdout
  #
  # Returns:
  #   0 on success
  #   1 if arguments are missing
  #
  # Example:
  #   # Replace spaces with underscores and dots with dashes
  #   result=$(pu_str_substitute "hello world.txt" " ." "_-")
  #   echo "$result"
  #   # Output: hello_world-txt

  if [ -z "$1" ]; then
    pu_log_e "PU6|03|pu_str_substitute requires at least the original string argument"
    return 1
  fi

  if [ -z "$2" ] || [ -z "$3" ]; then
    pu_log_w "PU6|03|pu_str_substitute: no substitution specified, returning original string"
    printf '%s' "$1"
    return 0
  fi

  printf '%s' "$1" | tr "$2" "$3"
}

pu_log_i "PU6|String utilities module loaded successfully"
