#!/bin/sh

# shellcheck source-path=SCRIPTDIR/..

pu_test_fatal() {
  __test_red='\033[0;31m' # Red
  __clr_reset='\033[0m'
  printf "PU_TEST|%bERROR: %s%b\n" "${__test_red}" "${1}" "${__clr_reset}" >&2
  unset __test_red __clr_reset
  exit "${2}"
}

oneTimeSetUp() {
  export PU_HOME="${PU_HOME:-$(cd "$(dirname "$0")/.." && pwd)}"
  if [ ! -f "${PU_HOME}/code/1.init.sh" ]; then
    pu_test_fatal "PU_HOME incorrect: ${PU_HOME}" 1
  fi

  . "${PU_HOME}/code/1.init.sh"
  . "${PU_HOME}/code/2.audit.sh"
  . "${PU_HOME}/code/3.ingester.sh"
  . "${PU_HOME}/code/4.common.sh"
  . "${PU_HOME}/code/5.network.sh"
  . "${PU_HOME}/code/6.string.sh"
  . "${PU_HOME}/code/7.data.sh"
}

test_1_init_funcs() {
  command -V 'pu_init_hunt_for_pu_file' 2>/dev/null | grep -qwi function
  assertTrue \
    "Have pu_init_hunt_for_pu_file file function" \
    $?
}

test_1_init_vars() {
  # Color reset is reusable everywhere
  assertTrue \
    "Internal color reset code exists and is global private" \
    "[ -n \"${__1__clr_reset}\" ]"
}

test_2_session() {
  assertTrue \
    "Session log exists" \
    "[ -f ""${__2__audit_session_dir}/session.log"" ]"
}

test_3_assure_real_public_file() {
  # This test assumes that the ingester.sh module is correctly sourced
  # and that the PU_HOME environment variable is set to the correct path.

  pu_assure_public_file "maven" \
    "https://repo1.maven.org" \
    "maven2/com/github/johrstrom/jmeter-prometheus-plugin/0.6.0" \
    "jmeter-prometheus-plugin-0.6.0.jar" \
    "eaa14d0769ede20da41fe905a25f34bc3ddfbbd462395e52755d8d2bcca1c2d6"

  __test_result=$?

  # 3. Verify function succeeded with real checksum
  assertEquals "Public file assurance check" 0 ${__test_result}
}

test_6_url_encode_simple_string() {
  __result_6_1=$(pu_urlencode "hello world")
  assertEquals "Space should be encoded as %20" "hello%20world" "${__result_6_1}"
  unset __result_6_1
}

test_7_csv_2_lines_simple() {
  __result_7_2=$(pu_csv_to_lines "apple,banana,cherry")
  __line_count_7_2=$(echo "${__result_7_2}" | wc -l)
  assertEquals "CSV should convert to 3 lines" 3 "${__line_count_7_2}"
  unset __result_7_2 __line_count_7_2
}

# shellcheck disable=SC1090
. "$(which shunit2)"
