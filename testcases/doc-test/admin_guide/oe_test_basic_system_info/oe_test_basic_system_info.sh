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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020.04-28
# @License   :   Mulan PSL v2
# @Desc      :   View system information
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase!"
    grep 'NAME="openEuler"' /etc/os-release
    CHECK_RESULT $?
    OS_VERSION=$(grep -w "VERSION" /etc/os-release | awk -F '"' '{print$2}')
    CHECK_RESULT $?
    grep 'ID="openEuler"' /etc/os-release
    CHECK_RESULT $?
    OS_VERSION_bak=${OS_VERSION} | awk '{print$1}'
    CHECK_RESULT $?
    grep 'VERSION_ID="$OS_VERSION_bak"' /etc/os-release
    CHECK_RESULT $?
    grep 'PRETTY_NAME="openEuler $OS_VERSION"' /etc/os-release
    CHECK_RESULT $?
    grep 'ANSI_COLOR="0;31"' /etc/os-release
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

main $@
