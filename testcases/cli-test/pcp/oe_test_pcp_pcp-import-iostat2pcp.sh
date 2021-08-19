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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/11/10
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in pcp-import-iostat2pcp binary package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "pcp-import-iostat2pcp sysstat"
    export LC_ALL=en_US.UTF-8
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    iostat -c 2 6 >inputfile
    CHECK_RESULT $?
    test -f inputfile
    CHECK_RESULT $?
    iostat2pcp -v inputfile iospcp | grep "End of sample"
    CHECK_RESULT $?
    test -f iospcp.0 -a -f iospcp.index -a -f iospcp.meta && rm -rf iospcp.0 iospcp.index iospcp.meta
    CHECK_RESULT $?
    iostat2pcp inputfile iospcp | grep "End of sample"
    CHECK_RESULT $? 0 1
    test -f iospcp.0 -a -f iospcp.index -a -f iospcp.meta && rm -rf iospcp.0 iospcp.index iospcp.meta
    CHECK_RESULT $?
    iostat2pcp -v -S 00:05:00 inputfile iospcp | grep -E "00:05:15|00:05:30"
    CHECK_RESULT $?
    test -f iospcp.0 -a -f iospcp.index -a -f iospcp.meta && rm -rf iospcp.0 iospcp.index iospcp.meta
    CHECK_RESULT $?
    iostat2pcp -v -S 00:05:00 -t 2 inputfile iospcp | grep -E "interval=2|00:05:02|00:05:04"
    CHECK_RESULT $?
    test -f iospcp.0 -a -f iospcp.index -a -f iospcp.meta && rm -rf iospcp.0 iospcp.index iospcp.meta
    CHECK_RESULT $?
    iostat2pcp -v -Z -3333 inputfile iospcp | grep "zone=-3333"
    CHECK_RESULT $?
    test -f iospcp.0 -a -f iospcp.index -a -f iospcp.meta && rm -rf iospcp.0 iospcp.index iospcp.meta
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf inputfile
    LOG_INFO "End to restore the test environment."
}

main "$@"
