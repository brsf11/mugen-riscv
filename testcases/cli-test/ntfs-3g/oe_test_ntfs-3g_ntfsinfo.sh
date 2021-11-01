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
# @Desc      :   verify the uasge of ntfsinfo command
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
    ntfsinfo --help 2>&1 | grep "Usage: ntfsinfo \[options\]"
    CHECK_RESULT $? 0 0 "Check ntfsinfo --help failed."
    ntfsinfo --version 2>&1 | grep "ntfsinfo v"
    CHECK_RESULT $? 0 0 "Check ntfsinfo --version failed."
    ntfsinfo --inode 5 /dev/${disk1} | grep "End of inode reached"
    CHECK_RESULT $? 0 0 "Check ntfsinfo --inode failed."
    ntfsinfo /dev/${disk1} --file test.txt | grep "End of inode reached"
    CHECK_RESULT $? 0 0 "Check ntfsinfo --file failed."
    ntfsinfo /dev/${disk1} --mft | grep "FILE_Bitmap Data Attribute Information"
    CHECK_RESULT $? 0 0 "Check ntfsinfo --mft failed."
    ntfsinfo /dev/${disk1} -t --inode 5 | grep "End of inode reached"
    CHECK_RESULT $? 0 0 "Check ntfsinfo --notime failed."
    ntfsinfo /dev/${disk1} --force --inode 5 | grep "End of inode reached"
    CHECK_RESULT $? 0 0 "Check ntfsinfo --force failed."
    ntfsinfo /dev/${disk1} --quiet --inode 5 | grep "End of inode reached"
    CHECK_RESULT $? 0 0 "Check ntfsinfo --quiet failed."
    ntfsinfo /dev/${disk1} --verbose --inode 5 | grep "End of inode reached"
    CHECK_RESULT $? 0 0 "Check ntfsinfo --verbose failed."
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
