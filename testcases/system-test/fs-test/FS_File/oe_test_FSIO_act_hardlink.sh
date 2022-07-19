#!/usr/bin/bash

# Copyright (c) 2022.Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   @meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2020-12-01
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test hard link file
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    file="testFile"$cur_date
    echo "test file" >/tmp/$file
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    hard_link="testHard"$cur_date
    ln /tmp/$file /tmp/$hard_link
    inode1=$(stat /tmp/$file | grep Inode | cut -d : -f 3 | awk '{print $1}')
    inode2=$(stat /tmp/$hard_link | grep Inode | cut -d : -f 3 | awk '{print $1}')
    CHECK_RESULT $inode1 $inode2 0 "The inode of source file and hard link file are not same."
    grep "test" /tmp/$hard_link
    CHECK_RESULT $? 0 0 "Check hard link file /tmp/$hard_link failed."
    sed -i "ahard" /tmp/$hard_link 
    grep "hard" /tmp/$hard_link
    CHECK_RESULT $? 0 0 "Check hard link file /tmp/$hard_link failed."
    sed -i "asource" /tmp/$file 
    grep "source" /tmp/$file
    CHECK_RESULT $? 0 0 "Check hard link file /tmp/$hard_link failed."
    rm -f /tmp/$hard_link 
    grep "source" /tmp/$file
    CHECK_RESULT $? 0 0 "Check source file /tmp/$file failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f /tmp/$file 
    LOG_INFO "End to restore the test environment."
}

main $@

