#!/usr/bin/bash

#Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Common network command test-ping
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."

    echo "${NODE1_IPV4} www.mytest.com" >> /etc/hosts
    ping -c 3 www.mytest.com
    CHECK_RESULT $? 0 0 "check ping -c fail"
    ping -h 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check ping help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    sed -i '/mytest/d' /etc/hosts

    LOG_INFO "End to restore the test environment."
}

main "$@"
