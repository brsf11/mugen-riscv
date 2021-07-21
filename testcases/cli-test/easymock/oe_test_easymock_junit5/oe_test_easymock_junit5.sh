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
# @Author    :   tangxiaolan
# @Contact   :   tangxiaolan0712@163.com
# @Date      :   2020/5/14
# @License   :   Mulan PSL v2
# @Desc      :   Easymock with JUnit5
# ############################################

source "../common/common_easymock.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    DNF_INSTALL maven
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mvn test | grep "Tests run: 1, Failures: 0, Errors: 0, Skipped: 0"$'\n'"BUILD SUCCESS"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
