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

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    file="testFile"$cur_date
    echo "test file" >/tmp/$file
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    soft_link="testSoft"$cur_date
    ln -s /tmp/$file /tmp/$soft_link
    inode1=$(stat /tmp/$file | grep Inode | cut -d : -f 3 | awk '{print $1}')
    inode2=$(stat /tmp/$soft_link | grep Inode | cut -d : -f 3 | awk '{print $1}')
    [[ $inode1 -ne $inode2 ]]
    CHECK_RESULT $? 0 0 "Check inode failed."
    grep "test" /tmp/$soft_link
    CHECK_RESULT $? 0 0 "The sort link file has some errors."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f /tmp/$soft_link /tmp/$file
    LOG_INFO "End to restore the test environment."
}

main $@

