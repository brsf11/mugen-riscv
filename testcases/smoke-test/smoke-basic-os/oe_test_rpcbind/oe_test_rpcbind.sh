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
# @Date      :   2022/06/14
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of rpcbind
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "net-tools rpcbind"
    systemctl start rpcbind
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ps aux | grep rpcbind
    CHECK_RESULT $? 0 0 "Failed to check rpcbind"
    netstat -tulnp | grep rpcbind | grep tcp | grep 111
    CHECK_RESULT $? 0 0 "Failed to execute netstat"
    rpcinfo -b 100004 2
    CHECK_RESULT $? 0 0 "Failed to execute rpcbind"
    ps aux | grep rpcbind
    CHECK_RESULT $? 0 0 "Failed to display rpcbind"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
