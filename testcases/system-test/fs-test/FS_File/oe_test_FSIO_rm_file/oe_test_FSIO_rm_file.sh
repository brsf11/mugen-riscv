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
#@Desc      	:   Take the test remove file
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    cp ./test.sh /tmp/testfile$cur_date
    bash /tmp/testfile$cur_date &
    touch /mnt/accessfile$cur_date
    chattr +i /mnt/accessfile$cur_date
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    rm -f /tmp/testfile$cur_date
    ls /tmp | grep /tmp/testfile$cur_date
    CHECK_RESULT $? 1 0 "Remove file /tmp/testfile$cur_date which used on backend failed."
    rm -f /mnt/accessfile$cur_date 2>&1 | grep "Operation not permitted"
    CHECK_RESULT $? 0 0 "Remove file /mnt/accessfile$cur_date which doesn't have access unexpectly."
    rm -f /tmp/noexist$cur_date 2>&1 | grep "No such file or directory"
    CHECK_RESULT $? 0 0 "The msg of remove non-exist file is error."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    chattr -i /mnt/accessfile$cur_date
    rm -f /mnt/accessfile$cur_date
    LOG_INFO "End to restore the test environment."
}

main $@

