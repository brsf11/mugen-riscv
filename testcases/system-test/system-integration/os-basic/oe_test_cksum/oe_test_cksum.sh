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
# @Date      :   2022-11-14
# @License   :   Mulan PSL v2
# @Desc      :   Command test-cksum 
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
    echo "111" >testfile1
    CHECK_RESULT $? 0 0 "check create file fail"
    sum=`cksum testfile1 |awk '{print$1}'`
    CHECK_RESULT $? 0 0  "check integrity of file fail"
    echo "222" >testfile1
    CHECK_RESULT $? 0 0 "check modify file fail"
    cksum testfile1 |awk '{print$1}'|grep $sum
    CHECK_RESULT $? 0 1 
    cksum --help|grep cksum
    CHECK_RESULT $? 0 0  "check command fail"
    cksum --version|grep "[0-9].[0-9]"
    CHECK_RESULT $? 0 0  "check command fail"
    rm -rf testfile1
    CHECK_RESULT $? 0 0 "check delete file fail"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    export LANG=${OLD_LANG}
    LOG_INFO "Finish environment cleanup!"
}

main "$@"



