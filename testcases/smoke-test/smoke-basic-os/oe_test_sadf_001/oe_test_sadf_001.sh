#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   zhaozhenyang
# @Contact   :   zhaozhenyang@uniontech.com
# @Date      :   2022.9.04
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-sadf
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test(){
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "sysstat"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start testing..."
    sar 1 10 -o test.data
    CHECK_RESULT $? 0 0 "Failure to Collect Information"
    test -f test.data
    CHECK_RESULT $? 0 0 "Failed to generate a file"
    sadf test.data | grep -w "%system"
    CHECK_RESULT $? 0 0 "Failed to parse the file"
    LOG_INFO " End testing..."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf test.data
    DNF_REMOVE 
    LOG_INFO "Finish environment cleanup!"
}

main $@
