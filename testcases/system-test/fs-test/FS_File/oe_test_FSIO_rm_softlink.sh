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
#@Date      	:   2020-12-01
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test soft link file
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function config_params() {
    LOG_INFO "Start parameters preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    file="testFile"$cur_date
    soft_file="softFile"$cur_date
    echo "create for test" >/tmp/$file
    ln -s /tmp/$file /tmp/$soft_file
    LOG_INFO "End of parameters preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    rm -f /tmp/$file
    CHECK_RESULT $? 0 0 "Remove origin soft link file /tmp/$file failed."
    cat $soft_file 2>&1 | grep "No such file or directory"
    CHECK_RESULT $? 0 0 "The soft link file has some errors."
    echo "delete and create" >/tmp/$file
    grep "delete and create" /tmp/$soft_file
    CHECK_RESULT $? 0 0 "The soft link file has some errors."
    rm -f /tmp/$soft_file
    grep "delete and create" /tmp/$file
    CHECK_RESULT $? 0 0 "The source file has some errors."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f /tmp/$file
    LOG_INFO "End to restore the test environment."
}

main $@

