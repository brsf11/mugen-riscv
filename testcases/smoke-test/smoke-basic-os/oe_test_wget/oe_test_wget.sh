#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/06/09
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of wget
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL bc
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    wget https://repo.openeuler.org/openEuler-22.03-LTS/ISO/aarch64/openEuler-22.03-LTS-aarch64-dvd.iso.sha256sum
    CHECK_RESULT $? 0 0 "Failed to execute wget"
    ls -l | grep 102
    CHECK_RESULT $? 0 0 "Failed to download"
    wget -O test.tar.gz https://repo.openeuler.org/openEuler-22.03-LTS/ISO/aarch64/openEuler-22.03-LTS-aarch64-dvd.iso.sha256sum --no-check-certificate
    CHECK_RESULT $? 0 0 "Failed to execute wget -O"
    ls -l | grep test.tar.gz | grep 102
    CHECK_RESULT $? 0 0 "Failed to find test.tar.gz"
    rm -rf openEuler-22.03-LTS-aarch64-dvd.iso*
    timeout 30 wget --limit-rate=1M https://repo.openeuler.org/openEuler-22.03-LTS/ISO/aarch64/openEuler-22.03-LTS-aarch64-dvd.iso
    CHECK_RESULT $? 0 1 "Failed to execute wget --limit"
    ISO_SIZE=$(ls -l | grep openEuler-22.03-LTS-aarch64-dvd.iso | awk '{print $5}')
    DOWNLOAD=$(echo "$ISO_SIZE/1024/30" | bc)
    test $DOWNLOAD -le 1024
    CHECK_RESULT $? 0 0 "Failed to limit download rate"
    rm -rf openEuler-22.03-LTS-aarch64-dvd.iso*
    wget https://repo.openeuler.org/openEuler-22.03-LTS/ISO/aarch64/openEuler-22.03-LTS-aarch64-dvd.iso &
    CHECK_RESULT $? 0 0 "Failed to execute wget on backgroud"
    SLEEP_WAIT 5
    kill -9 $(pgrep wget)
    CHECK_RESULT $? 0 0 "Failed to kill wget"
    wget -c https://repo.openeuler.org/openEuler-22.03-LTS/ISO/aarch64/openEuler-22.03-LTS-aarch64-dvd.iso &
    CHECK_RESULT $? 0 0 "Failed to execute wget -c"
    SLEEP_WAIT 5
    kill -9 $(pgrep wget)
    CHECK_RESULT $? 0 0 "Failed to kill -9 wget"
    ls ./ | grep -c "openEuler-22.03-LTS-aarch64-dvd.iso" | grep 1
    CHECK_RESULT $? 0 0 "Failed to continue execute wget"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf openEuler-22.03-LTS-aarch64-dvd.iso* wget-log* test.tar.gz
    LOG_INFO "End to restore the test environment."
}

main "$@"
