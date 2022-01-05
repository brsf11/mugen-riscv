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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-29
# @License   :   Mulan PSL v2
# @Desc      :   Query system version info test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start to run test."
    OS_VERSION=$(awk '{print$3}' /etc/openEuler-release)
    grep "NAME" /etc/os-release | grep "openEuler"
    CHECK_RESULT $?
    grep -w "VERSION" /etc/os-release | awk -F '"' '{print$2}' | grep -w "${OS_VERSION}"
    CHECK_RESULT $?
    grep -E "^ID" /etc/os-release | grep "openEuler"
    CHECK_RESULT $?
    grep -E "VERSION_ID" /etc/os-release | grep "$OS_VERSION"
    CHECK_RESULT $?
    grep -E "PRETTY_NAME" /etc/os-release | grep "openEuler $OS_VERSION"
    CHECK_RESULT $?
    grep -E "ANSI_COLOR" /etc/os-release | grep "0;31"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

main "$@"
