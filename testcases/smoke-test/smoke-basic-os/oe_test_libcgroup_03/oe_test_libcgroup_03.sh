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
# @Date      :   2022/06/13
# @License   :   Mulan PSL v2
# @Desc      :   Test cgexec
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL libcgroup
    cgcreate -g cpu:test
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cgexec -g cpu:test ip a | grep ${NODE1_IPV4}
    CHECK_RESULT $? 0 0 "Failed to execute cgexec"
    ping -q www.baidu.com &
    ping_pid=$(ps -aux | grep "ping -q www.baidu.com" | grep -v grep | awk '{print $2}')
    cgclassify -g cpu:test $ping_pid
    CHECK_RESULT $? 0 0 "Failed to execute cgclassify"
    grep $ping_pid /sys/fs/cgroup/cpu/test/tasks
    CHECK_RESULT $? 0 0 "Failed to display pid"
    kill -9 $ping_pid
    cat /sys/fs/cgroup/cpu/test/tasks | wc -l | grep 0
    CHECK_RESULT $? 0 0 "File is not empty"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    cgdelete -g cpu:test
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
