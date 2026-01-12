#!/bin/sh


# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

if [ -z ${__pu_audit_session_file+x} ]; then
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
  pu_read_secret_from_user_s1="a"
  pu_read_secret_from_user_s2="a"
  while [ "${secret}" = "0" ]; do
    printf "Please input %s: " "${1}"
    read -r pu_read_secret_from_user_s1
    printf "\n"
    printf "Please input %s again: " "${1}"
    read -r pu_read_secret_from_user_s2
    printf "\n"
    if [ "${pu_read_secret_from_user_s1}" = "${pu_read_secret_from_user_s2}" ]; then
      secret=${pu_read_secret_from_user_s1}
    else
      echo "Inputs do not match, please retry!"
    fi
    unset pu_read_secret_from_user_s1 pu_read_secret_from_user_s2
  done
  stty echo
}
