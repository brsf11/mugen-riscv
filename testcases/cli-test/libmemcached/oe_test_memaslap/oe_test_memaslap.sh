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
# @Date      :   2020/10/27
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of memaslap command
# ############################################

source "../common/common_libmemcached.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    memaslap --help | grep "-"
    CHECK_RESULT $?
    memaslap -V | grep "memslap.*.[0-9]"
    CHECK_RESULT $?
    memaslap -s 127.0.0.1:11211 -S 5s -t 15s | tee log
    CHECK_RESULT $?
    grep -E "servers : 127.0.0.1:11211|run time: 15s|Period.*5" log
    CHECK_RESULT $?
    memaslap -s 127.0.0.1:11211 -t 10s -v 0.2 -e 0.05 -b | tee log
    CHECK_RESULT $?
    grep -E "servers : 127.0.0.1:11211|run time: 10s" log
    CHECK_RESULT $?
    memaslap -s 127.0.0.1:11211 -F config -t 12s -w 40k -S 3s -o 0.2 | tee log
    CHECK_RESULT $?
    grep -E "servers : 127.0.0.1:11211|run time: 12s|windows size: 40k|Period.*3" log
    CHECK_RESULT $?
    memaslap -s 127.0.0.1:11211 -F config -t 5s | tee log
    CHECK_RESULT $?
    grep -E "servers : 127.0.0.1:11211|run time: 5s" log
    CHECK_RESULT $?
    memaslap -s 127.0.0.1:11211 -F config -t 2s -T 4 -c 128 -d 20 -P 40k | tee log
    CHECK_RESULT $?
    grep -E "servers : 127.0.0.1:11211|run time: 2s|threads count: 4|concurrency: 128" log
    CHECK_RESULT $?
    memaslap -s 127.0.0.1:11211 -F config -t 4s -d 50 -a -n 40 | tee log
    CHECK_RESULT $?
    grep -E "servers : 127.0.0.1:11211|run time: 4s" log
    CHECK_RESULT $?
    memcached -d -u root -m 512 -l 127.0.0.1 -p 11212
    CHECK_RESULT $?
    memaslap -s 127.0.0.1:11211,127.0.0.1:11212 -F config -t 5s -p 2 | tee log
    CHECK_RESULT $?
    grep -E "servers : 127.0.0.1:11211,127.0.0.1:11212|run time: 5s" log
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
