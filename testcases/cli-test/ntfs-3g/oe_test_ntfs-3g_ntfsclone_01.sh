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
# @Desc      :   verify the uasge of ntfsclone command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfsclone --help 2>&1 | grep "Usage: ntfsclone \[OPTIONS\]"
    CHECK_RESULT $? 0 0 "Check ntfsclone --help failed."
    ntfsclone --version 2>&1 | grep "ntfsclone v"
    CHECK_RESULT $? 0 0 "Check ntfsclone --version failed."
    ntfsclone --output test.txt /dev/${disk1} 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --output failed."
    ntfsclone --overwrite /dev/${disk1} /dev/${disk2} 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --overwrite failed."
    ntfsclone --save-image --output backup.img /dev/${disk1} 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --save-image failed."
    ntfsclone --restore-image --overwrite /dev/${disk1} backup.img 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --restore-image failed."
    ntfsclone --metadata --output ntfsmeta.img /dev/${disk1} 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --metadata failed."
    ntfsclone --overwrite /dev/${disk1} /dev/${disk2} --rescue 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --rescue failed."
    ntfsclone --restore-image backup.img --no-action 2>&1 | grep "completed"
    CHECK_RESULT $? 0 0 "Check ntfsclone --no-action failed."
    ntfsclone --metadata --overwrite ntfsmeta.img /dev/${disk1} --ignore-fs-check 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --ignore-fs-check failed."
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
    rm -rf test.txt backup.img ntfsmeta.img
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
