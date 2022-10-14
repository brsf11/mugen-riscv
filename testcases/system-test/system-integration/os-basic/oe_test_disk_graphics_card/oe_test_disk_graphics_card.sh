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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Command test-who -b/-s
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to pre the test env"
    DNF_INSTALL dmidecode
    LOG_INFO "End to pre the test env"
}
function run_test() {
    LOG_INFO "Start to run test."
    lspci -vnn | grep QEMU -A 12
    CHECK_RESULT $?
    dmidecode -s bios-vendor | grep -iE "EFI Development Kit II / OVMF|SeaBIOS"
    CHECK_RESULT $?
    dmidecode -s bios-version | grep -iE "0.0.0|prebuilt.qemu.org"
    CHECK_RESULT $?
    id -u testuser || useradd testuser
    usermod -s /bin/csh testuser
    CHECK_RESULT $?
    su testuser -c "echo $SHELL" | grep "/bin/csh"
    CHECK_RESULT $? 0 1
    sudo lshw -c network | grep "network"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to clean env."
    userdel -rf testuser
    DNF_REMOVE
    LOG_INFO "End to clean env."
}
main "$@"
