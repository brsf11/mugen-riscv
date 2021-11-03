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
# @Desc      :   verify the uasge of lowntfs-3g command
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
    lowntfs-3g /dev/${disk1} /mnt/windows -o hide_dot_files
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o hide_dot_files failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o windows_names
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o windows_names failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o allow_other
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o allow_other failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o max_read=1000
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o max_read failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o silent
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o silent failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o no_def_opts
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o no_def_opts failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o streams_interface=none
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o streams_interface failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o user_xattr
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o user_xattr failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o efs_raw
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o efs_raw failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o compression
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o compression failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o nocompression
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o nocompression failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o big_writes
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o big_writes failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o debug
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o debug failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    lowntfs-3g /dev/${disk1} /mnt/windows -o ignore_case
    CHECK_RESULT $? 0 0 "Check lowntfs-3g -o ignore_case failed."
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
