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
# @Desc      :   verify the uasge of ntfscat ntfs-3g.probe command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfscat --help 2>&1 | grep "Usage: ntfscat \[options\]"
    CHECK_RESULT $? 0 0 "Check ntfscat --help failed."
    ntfscat --version 2>&1 | grep "ntfscat v"
    CHECK_RESULT $? 0 0 "Check ntfscat --version failed."
    ntfscat /dev/${disk1} --inode 5 --attribute INDEX_ROOT
    CHECK_RESULT $? 0 0 "Check ntfscat --attribute failed."
    ntfscat /dev/${disk1} --inode 15 --attribute-name ""
    CHECK_RESULT $? 0 0 "Check ntfscat --attribute-name failed."
    ntfscat /dev/${disk1} --inode 4 --force
    CHECK_RESULT $? 0 0 "Check ntfscat --force failed."
    ntfscat /dev/${disk1} --inode 4 --quiet
    CHECK_RESULT $? 0 0 "Check ntfscat --quiet failed."
    ntfscat /dev/${disk1} --inode 4 --verbose
    CHECK_RESULT $? 0 0 "Check ntfscat --verbose failed."
    ntfs-3g.probe --help 2>&1 | grep "Usage:.*ntfs-3g.probe"
    CHECK_RESULT $? 0 0 "Check ntfs-3g.probe --help failed."
    ntfs-3g.probe --readonly /dev/${disk1}
    CHECK_RESULT $? 0 0 "Check ntfs-3g.probe --readonly failed."
    ntfs-3g.probe --readwrite /dev/${disk1}
    CHECK_RESULT $? 0 0 "Check ntfscat ntfs-3g.probe --readwrite failed."
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
