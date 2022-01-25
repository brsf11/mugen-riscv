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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020.4-9
# @License   :   Mulan PSL v2
# @Desc      :   Package operations
# #############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start executing testcase."
    DNF_INSTALL httpd
    LOG_INFO "End of testcase execution."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    dnf search httpd | grep httpd
    CHECK_RESULT $?
    dnf list all >/dev/null
    CHECK_RESULT $?
    dnf info httpd | grep httpd | grep -i Name
    CHECK_RESULT $?
    dnf download httpd
    CHECK_RESULT $?
    find httpd-*
    CHECK_RESULT $?
    dnf remove httpd -y
    CHECK_RESULT $?
    dnf download --resolve httpd
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf *.rpm httpd-*
    LOG_INFO "Finish environment cleanup."
}

main $@
