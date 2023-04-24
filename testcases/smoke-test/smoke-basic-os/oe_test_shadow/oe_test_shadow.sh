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
# @Date      :   2022/07/01
# @License   :   Mulan PSL v2
# @Desc      :   Test shadow file
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    getenforce | grep -i Permissive && setenforce 1
    groupadd -o -g 32 rpctest
    SLEEP_WAIT 3
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    useradd -o -c "Rpcbind Daemon" -d /var/lib/rpcbind -g 32 -M -s /sbin/nologin -u 10000 rpctest
    CHECK_RESULT $? 0 0 "Failed to execute useradd"
    chage -l rpctest | grep "99999"
    CHECK_RESULT $? 0 0 "Failed to execute chage -l"
    chage -M 99998 rpctest
    CHECK_RESULT $? 0 0 "Failed to execute chage -M"
    chage -l rpctest | grep "99998"
    CHECK_RESULT $? 0 0 "Failed to change rpctest"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    groupdel -f rpctest
    userdel -rf rpctest
    LOG_INFO "End to restore the test environment."
}

main "$@"
