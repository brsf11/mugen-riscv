#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   @meitingli
#@Contact   	:   bubble_mt@outlook.com
#@Date      	:   2020-11-30
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test create file failed
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_lang=$(echo $LANG)
    export LANG=en_US.UTF-8
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    cur_date=$(date +%Y%m%d%H%M%S)
    touch 2>&1 | grep "missing file operand"
    CHECK_RESULT $? 0 0 "Create file without file operand succeed."
    touch "testaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"$cur_date 2>&1 | grep "File name too long"
    CHECK_RESULT $? 0 0 "File can be created when length of file name is more than 255."
    touch /tmp/"a"$cur_date /tmp/"b"$cur_date 
    cat /tmp/"a"$cur_date
    CHECK_RESULT $? 0 0 "Create file a failed."
    cat /tmp/"b"$cur_date
    CHECK_RESULT $? 0 0 "Create file b failed."
    touch /tmp/{"a"$cur_date:1,"b"$cur_date:2}
    cat /tmp/"a"$cur_date:1
    CHECK_RESULT $? 0 0 "Create file a:1 failed."
    cat /tmp/"b"$cur_date:2
    CHECK_RESULT $? 0 0 "Create file b:2 failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    export LANG=$cur_lang
    rm -rf /tmp/"a"$cur_date /tmp/"b"$cur_date /tmp/"a"$cur_date:1 /tmp/"b"$cur_date:2
    LOG_INFO "End to restore the test environment."
}

main $@
