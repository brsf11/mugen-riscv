#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wenjun
# @Contact   :   1009065695@qq.com
# @Date      :   2021/10/25
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of ntfswipe command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfswipe --help 2>&1 | grep "Usage: ntfswipe \[options\]"
    CHECK_RESULT $? 0 0 "Check ntfswipe --help failed."
    ntfswipe --version 2>&1 | grep "ntfswipe v"
    CHECK_RESULT $? 0 0 "Check ntfswipe --version failed."
    ntfswipe --info /dev/${disk1} | grep "bytes would be wiped"
    CHECK_RESULT $? 0 0 "Check ntfswipe --info failed."
    ntfswipe --directory /dev/${disk1} | grep "bytes were wiped"
    CHECK_RESULT $? 0 0 "Check ntfswipe --directory failed."
    ntfswipe --logfile /dev/${disk1} | grep "bytes were wiped"
    CHECK_RESULT $? 0 0 "Check ntfswipe --logfile failed."
    ntfswipe --mft /dev/${disk1} | grep "bytes were wiped" 
    CHECK_RESULT $? 0 0 "Check ntfswipe --mft failed."
    ntfswipe --pagefile /dev/${disk1} | grep "bytes were wiped" 
    CHECK_RESULT $? 0 0 "Check ntfswipe --pagefile failed."
    ntfswipe --tails /dev/${disk1} | grep "bytes were wiped" 
    CHECK_RESULT $? 0 0 "Check ntfswipe --tails failed."
    ntfswipe --unused /dev/${disk1} | grep "bytes were wiped" 
    CHECK_RESULT $? 0 0 "Check ntfswipe --unused failed."
    ntfswipe --unused-fast /dev/${disk1} | grep "bytes were wiped" 
    CHECK_RESULT $? 0 0 "Check ntfswipe --unused-fast failed."
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    expect <<EOF
    spawn mkfs.ext4 /dev/${disk1}
    send "y\n"
    expect eof
EOF
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
