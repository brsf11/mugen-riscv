#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
#@Date      	:   2020-11-18
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test access of /usr
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
    ls -l /usr | awk '{print $9}' >./actual_name$cur_date
    diff ./actual_name$cur_date ./expect_name
    CHECK_RESULT $? 0 0 "The directory or file on /usr has some errors."
    ls -l /usr | awk '{print $1}' | grep -v "total" | sort | uniq | cut -c 1-10 >./actual_access$cur_date
    diff ./actual_access$cur_date ./expect_access
    CHECK_RESULT $? 0 0 "The access of directory or file on /usr has some errors."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    export LANG=$cur_lang
    rm -rf ./actual_name$cur_date ./actual_access$cur_date
    LOG_INFO "End to restore the test environment."
}

main "$@"

