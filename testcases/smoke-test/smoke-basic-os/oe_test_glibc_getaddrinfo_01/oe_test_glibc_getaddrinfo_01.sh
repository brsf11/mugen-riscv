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
# @Desc      :   Test to get web address information
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "bind-utils traceroute mtr wget"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    flag=1
    while ((flag < 80)); do
        wget www.baidu.com
        CHECK_RESULT $? 0 0 "Failed to execute wget"
        test -f index.html && rm -rf index.html
        CHECK_RESULT $? 0 0 "Failed to execute wget"
        let flag+=1
    done
    curl www.baidu.com | grep "baidu"
    CHECK_RESULT $? 0 0 "Failed to execute curl"
    ping -c 3 www.baidu.com | grep "0% packet loss"
    CHECK_RESULT $? 0 0 "Failed to execute ping"
    host www.baidu.com | grep "baidu.com"
    CHECK_RESULT $? 0 0 "Failed to execute host"
    nslookup www.baidu.com | grep "canonical name"
    CHECK_RESULT $? 0 0 "Failed to execute nslookup"
    traceroute www.baidu.com | grep "traceroute to"
    CHECK_RESULT $? 0 0 "Failed to execute traceroute"
    mtr -r www.baidu.com | grep "Start:"
    CHECK_RESULT $? 0 0 "Failed to execute mtr"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
