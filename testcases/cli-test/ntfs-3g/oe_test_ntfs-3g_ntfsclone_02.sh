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
# @Desc      :   verify the uasge of ntfsclone ntfsfix command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfsclone --overwrite /dev/${disk1} /dev/${disk2} --new-serial 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --new-serial failed."
    ntfsclone --overwrite /dev/${disk1} /dev/${disk2} --new-half-serial 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --new-half-serial failed."
    ntfsclone --overwrite /dev/${disk1} /dev/${disk2} --preserve-timestamps 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --preserve-timestamps failed."
    ntfsclone --overwrite /dev/${disk1} /dev/${disk2} --quiet 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --quiet failed."
    ntfsclone --overwrite /dev/${disk1} /dev/${disk2} --force 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --force failed."
    ntfsclone --overwrite /dev/${disk1} /dev/${disk2} --full-logfile 2>&1 | grep "Syncing"
    CHECK_RESULT $? 0 0 "Check ntfsclone --full-logfile failed."
    ntfsfix --help 2>&1 | grep "Usage: ntfsfix \[options\]"
    CHECK_RESULT $? 0 0 "Check ntfsfix --help failed."
    ntfsfix --version 2>&1 | grep "ntfsfix v"
    CHECK_RESULT $? 0 0 "Check ntfsfix --version failed."
    ntfsfix --clear-bad-sectors /dev/${disk1} | grep "NTFS partition /dev/${disk1} was processed successfully"
    CHECK_RESULT $? 0 0 "Check ntfsfix --clear-bad-sectors failed."
    ntfsfix --clear-dirty /dev/${disk1} | grep "NTFS partition /dev/${disk1} was processed successfully"
    CHECK_RESULT $? 0 0 "Check ntfsfix --clear-dirty failed."
    ntfsfix --no-action /dev/${disk1} | grep "NTFS partition /dev/${disk1} was processed successfully"
    CHECK_RESULT $? 0 0 "Check ntfsfix --no-action failed."
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
