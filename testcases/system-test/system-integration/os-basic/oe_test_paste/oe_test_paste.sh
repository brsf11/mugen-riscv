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
# @Date      :   2022-11-29
# @License   :   Mulan PSL v2
# @Desc      :   Command test-paste 
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
    echo "222" >testfile2
    CHECK_RESULT $? 0 0 "check create file fail"    
    paste testfile1 testfile2|head -1|grep -E "111.*222"
    CHECK_RESULT $? 0 0  "Merge file contents in parallel fail"
    paste -s testfile1 testfile2|head -1|grep 111 &&paste -s testfile1 testfile2|head -2|grep 222
    CHECK_RESULT $? 0 0 "Merge file contents serially fail"
    echo aaa >test.txt && echo bbb >>test.txt
    CHECK_RESULT $? 0 0 "check create file fail"
    paste -s -d 1 test.txt|grep aaa1bbb
    CHECK_RESULT $? 0 0
    paste --help|grep paste
    CHECK_RESULT $? 0 0  "check command fail"
    paste --version|grep Copyright
    CHECK_RESULT $? 0 0  "check command fail"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf testfile1 testfile2 test.txt
    export LANG=${OLD_LANG}
    LOG_INFO "Finish environment cleanup!"
}

main "$@"



