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
# @Desc      :   verify the uasge of osinfo-query command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL libosinfo
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    osinfo-query --help | grep -E "Usage:|osinfo-query \[OPTION…\]"
    CHECK_RESULT $?
    osinfo-query os | grep "http:"
    CHECK_RESULT $?
    osinfo-query os vendor="Fedora Project" | grep "Fedora"
    CHECK_RESULT $?
    osinfo-query --sort=version os vendor="Fedora Project" | grep "[0-9]"
    CHECK_RESULT $?
    osinfo-query --sort=version os | grep -i "[0-9a-z]"
    CHECK_RESULT $?
    osinfo-query --fields=short-id,version os vendor="openSUSE" | grep "opensuse"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
