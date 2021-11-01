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
    ntfswipe --undel /dev/${disk1} | grep "bytes were wiped"
    CHECK_RESULT $? 0 0 "Check ntfswipe --undel failed."
    ntfswipe --all /dev/${disk1} | grep "bytes were wiped"
    CHECK_RESULT $? 0 0 "Check ntfswipe --all failed."
    ntfswipe --count 3 /dev/${disk1} | grep "bytes would be wiped"
    CHECK_RESULT $? 0 0 "Check ntfswipe --count failed."
    ntfswipe --bytes 3 /dev/${disk1} | grep "bytes would be wiped"
    CHECK_RESULT $? 0 0 "Check ntfswipe --bytes failed."
    ntfswipe --no-action /dev/${disk1} | grep "bytes would be wiped"
    CHECK_RESULT $? 0 0 "Check ntfswipe --no-action failed."
    ntfswipe --force /dev/${disk1} | grep "bytes would be wiped"
    CHECK_RESULT $? 0 0 "Check ntfswipe --force failed."
    ntfswipe --quiet /dev/${disk1} | grep "bytes would be wiped"
    CHECK_RESULT $? 0 0 "Check ntfswipe --quiet failed."
    ntfswipe --verbose /dev/${disk1} | grep "bytes would be wiped"
    CHECK_RESULT $? 0 0 "Check ntfswipe --verbose failed."
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
