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
#@Desc      	:   Take the test access of /sys
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    cur_date=$(date +%Y%m%d%H%M%S)
    ls /sys >./actual_name$cur_date
    actual=$(diff ./actual_name$cur_date ./expect_name)
    [[ "$actual" == "" || "$actual" =~ "hypervisor" ]]
    CHECK_RESULT $? 0 0 "The directory or file on /sys has some errors."
    ls -l /sys | awk '{print $1}' | grep -v "total" | sort | uniq | grep "drwxr-xr-x" >/dev/null
    CHECK_RESULT $? 0 0 "The access of directory or file on /sys has some errors."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf ./actual_name$cur_date
    LOG_INFO "End to restore the test environment."
}

main "$@"

