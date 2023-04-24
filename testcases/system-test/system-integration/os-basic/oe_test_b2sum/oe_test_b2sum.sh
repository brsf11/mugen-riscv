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
# @Author    :   deepin12
# @Contact   :   chenyia@uniontech.com
# @Date      :   2023-1-12
# @License   :   Mulan PSL v2
# @Desc      :   Command test-b2sum 
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8    
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    echo "123456" >testfile1
    CHECK_RESULT $? 0 0 "check create file fail"
    b2sum -b testfile1|grep "*testfile1"    
    CHECK_RESULT $? 0 0  "failed to read the file in binary. procedure"
    b2sum -l 8 testfile1|grep a1
    CHECK_RESULT $? 0 0  "Summary length failure"
    b2sum -t testfile1 |grep testfile1
    CHECK_RESULT $? 0 0  "Failed to read in plain text mode"
    b2sum --help|grep b2sum
    CHECK_RESULT $? 0 0  "check help manual fail"
    b2sum --version|grep b2sum    
    CHECK_RESULT $? 0 0  "check version fail"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf testfile1
    export LANG=${OLD_LANG}
    LOG_INFO "Finish environment cleanup!"
}

main "$@"



