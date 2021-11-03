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
# @Desc      :   verify the uasge of ntfs-3g command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    mkdir -p /mnt/windows
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfs-3g --help 2>&1 | grep "Usage:.*ntfs-3g"
    CHECK_RESULT $? 0 0 "Check ntfs-3g --help failed."
    ntfs-3g --version 2>&1 | grep "ntfs-3g"
    CHECK_RESULT $? 0 0 "Check ntfs-3g --version failed."
    ntfs-3g /dev/${disk1} /mnt/windows -o uid=1000,gid=1000
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o uid gid failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o umask=0777
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o umask failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o dmask=0777
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o dmask failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o usermapping=test.txt
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o usermapping failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o permissions
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o permissions failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o ro
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o ro failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o acl
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o acl failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o inherit
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o inherit failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
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
