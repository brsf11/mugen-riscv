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
# @Desc      :   verify the uasge of ntfsmove command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    mkdir -p /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows
    touch /mnt/windows/test.txt
    umount /mnt/windows
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfsmove --help 2>&1 | grep "Usage: ntfsmove \[options\]"
    CHECK_RESULT $? 0 0 "Check ntfsmove --help failed."
    ntfsmove --version 2>&1 | grep "ntfsmove v"
    CHECK_RESULT $? 0 0 "Check ntfsmove --version failed."
    ntfsmove --start /dev/${disk1} test.txt | grep "success"
    CHECK_RESULT $? 0 0 "Check ntfsmove --start failed."
    ntfsmove --best /dev/${disk1} test.txt | grep "success"
    CHECK_RESULT $? 0 0 "Check ntfsmove --best failed."
    ntfsmove --end /dev/${disk1} test.txt | grep "success"
    CHECK_RESULT $? 0 0 "Check ntfsmove --end failed."
    ntfsmove --cluster 5 /dev/${disk1} test.txt | grep "success"
    CHECK_RESULT $? 0 0 "Check ntfsmove --cluster failed."
    ntfsmove --no-dirty /dev/${disk1} test.txt | grep "success"
    CHECK_RESULT $? 0 0 "Check ntfsmove --no-dirty failed."
    ntfsmove --no-action /dev/${disk1} test.txt | grep "success"
    CHECK_RESULT $? 0 0 "Check ntfsmove --no-action failed."
    ntfsmove --force /dev/${disk1} test.txt | grep "success"
    CHECK_RESULT $? 0 0 "Check ntfsmove --force failed."
    ntfsmove --quiet /dev/${disk1} test.txt | grep "success"
    CHECK_RESULT $? 0 0 "Check ntfsmove --quiet failed."
    ntfsmove --verbose /dev/${disk1} test.txt | grep "success"
    CHECK_RESULT $? 0 0 "Check ntfsmove --verbose failed."
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    expect <<EOF
    spawn mkfs.ext4 /dev/${disk1}
    send "y\n"
    expect eof
EOF
    rm -rf /mnt/windows
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
