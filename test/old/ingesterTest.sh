#!/bin/sh

# Copyright IBM Corporation All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

testAssurePublicFileRealOnlineDownload() {
  # This test assumes that the ingester.sh module is correctly sourced
  # and that the PU_HOME environment variable is set to the correct path.

  export PU_CACHE_HOME="/tmp/pu-cache-test"
  export PU_ONLINE_MODE="true"
  export PU_INIT_INGESTER="true"

  # shellcheck source=SCRIPTDIR/../code/1.init.sh
  . "${PU_HOME}/code/1.init.sh"

  pu_assure_public_file "maven" \
    "https://repo1.maven.org" \
    "maven2/com/github/johrstrom/jmeter-prometheus-plugin/0.6.0" \
    "jmeter-prometheus-plugin-0.6.0.jar" \
    "eaa14d0769ede20da41fe905a25f34bc3ddfbbd462395e52755d8d2bcca1c2d6"

  __test_result=$?

  # 3. Verify function succeeded with real checksum
  assertEquals "Function should succeed with real checksum" 0 ${__test_result}
  unset PU_CACHE_HOME PU_HOME PU_ONLINE_MODE PU_INIT_INGESTER

}
