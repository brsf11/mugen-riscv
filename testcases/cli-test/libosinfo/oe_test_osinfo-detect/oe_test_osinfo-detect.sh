#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/29
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of osinfo-detect command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL libosinfo
    VERSION_ID=$(grep "VERSION_ID" /etc/os-release|awk -F '\"' '{print$2}')
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    osinfo-detect --help | grep -E "Usage:|osinfo-detect \[OPTION…\]"
    CHECK_RESULT $?
    nohup wget https://repo.openeuler.org/openEuler-20.03-LTS/ISO/aarch64/openEuler-20.03-LTS-aarch64-dvd.iso >/dev/null 2>&1 &
    SLEEP_WAIT 20
    if [ $VERSION_ID != "22.03" ]; then
        osinfo-detect --format=env openEuler-20.03-LTS-aarch64-dvd.iso
        CHECK_RESULT $?
    else
        LOG_INFO "Obsolete version command"
    fi 
    osinfo-detect --format=plain openEuler-20.03-LTS-aarch64-dvd.iso
    CHECK_RESULT $?
    osinfo-detect --type=media openEuler-20.03-LTS-aarch64-dvd.iso
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    kill -9 $(pgrep -f 'wget')
    roc=$(ls | grep -v ".sh")
    rm -rf $roc
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
