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
# @Desc      :   verify the uasge of ntfstruncate command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfstruncate --help 2>&1 | grep "Usage: ntfstruncate \[options\]"
    CHECK_RESULT $? 0 0 "Check ntfstruncate --help failed."
    ntfstruncate --version 2>&1 | grep "ntfstruncate v"
    CHECK_RESULT $? 0 0 "Check ntfstruncate --version failed."
    ntfstruncate -n /dev/${disk1} 7 10 | grep "ntfstruncate completed successfully"
    CHECK_RESULT $? 0 0 "Check ntfstruncate -n failed."
    ntfstruncate -f /dev/${disk1} 7 10 | grep "ntfstruncate completed successfully"
    CHECK_RESULT $? 0 0 "Check ntfstruncate -f failed."
    ntfstruncate -q /dev/${disk1} 7 10 2>&1 | grep "ntfstruncate"
    CHECK_RESULT $? 0 0 "Check ntfstruncate -q failed."
    ntfstruncate -v /dev/${disk1} 7 10 | grep "ntfstruncate completed successfully"
    CHECK_RESULT $? 0 0 "Check ntfstruncate -v failed."
    ntfstruncate -vv /dev/${disk1} 7 10 | grep "ntfstruncate completed successfully"
    CHECK_RESULT $? 0 0 "Check ntfstruncate -vv failed."
    ntfstruncate -l /dev/${disk1} 7 10 2>&1 | grep "ntfstruncate"
    CHECK_RESULT $? 0 0 "Check ntfstruncate -l failed."
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
