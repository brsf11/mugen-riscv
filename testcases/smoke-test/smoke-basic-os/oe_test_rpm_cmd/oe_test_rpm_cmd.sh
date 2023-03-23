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
# @Date      :   2022/06/25
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of rpm
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    tcllib_url=$(yumdownloader --resolve --url tcllib | grep http)
    rpm -ivh $tcllib_url
    CHECK_RESULT $? 0 0 "Failed to execute rpm -ivh"
    rpm -qa | grep -v help | grep tcllib
    CHECK_RESULT $? 0 0 "Failed to execute rpm -qa"
    rpm -e $(rpm -qa tcllib)
    CHECK_RESULT $? 0 0 "Failed to execute rpm -e"
    rpm -qa | grep -v help | grep tcllib
    CHECK_RESULT $? 0 1 "Succeed to display tcllib"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /etc/yum.repos.d/openeuler.repo
    LOG_INFO "End to restore the test environment."
}

main "$@"
