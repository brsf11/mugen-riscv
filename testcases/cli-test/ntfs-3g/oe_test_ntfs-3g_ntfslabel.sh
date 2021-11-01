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
# @Desc      :   verify the uasge of ntfslabel ntfscmp command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfslabel --help 2>&1 | grep "Usage: ntfslabel \[options\]"
    CHECK_RESULT $? 0 0 "Check ntfslabel --help failed"
    ntfslabel --version 2>&1 | grep "ntfslabel v"
    CHECK_RESULT $? 0 0 "Check ntfslabel --version failed"
    ntfslabel --no-action /dev/${disk1} 5
    CHECK_RESULT $? 0 0 "Check ntfslabel --no-action failed"
    ntfslabel --force /dev/${disk1} 5
    CHECK_RESULT $? 0 0 "Check ntfslabel --force failed"
    ntfslabel --new-serial /dev/${disk1} 5 | grep "New serial number"
    CHECK_RESULT $? 0 0 "Check ntfslabel --new-serial failed"
    ntfslabel --new-half-serial /dev/${disk1} 5 | grep "New serial number"
    CHECK_RESULT $? 0 0 "Check ntfslabel --new-half-serial failed"
    ntfslabel --quiet /dev/${disk1} 5
    CHECK_RESULT $? 0 0 "Check ntfslabel --quiet failed"
    ntfslabel --verbose /dev/${disk1} 5 | grep "Serial number"
    CHECK_RESULT $? 0 0 "Check ntfslabel --verbose failed"
    ntfscmp --help 2>&1 | grep "Usage: ntfscmp \[OPTIONS\]"
    CHECK_RESULT $? 0 0 "Check ntfscmp --help failed"
    ntfscmp --version 2>&1 | grep "ntfscmp v"
    CHECK_RESULT $? 0 0 "Check ntfscmp --version failed"
    ntfscmp --no-progress-bar /dev/${disk1} /dev/${disk2} | grep "ntfscmp"
    CHECK_RESULT $? 0 0 "Check ntfscmp --no-progress-bar failed"
    ntfscmp --verbose /dev/${disk1} /dev/${disk2} | grep "100.00 percent completed"
    CHECK_RESULT $? 0 0 "Check ntfscmp --verbose failed"
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    expect <<EOF
    spawn mkfs.ext4 /dev/${disk1}
    send "y\n"
    expect eof
EOF
    expect <<EOF
    spawn mkfs.ext4 /dev/${disk2}
    send "y\n"
    expect eof
EOF
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
