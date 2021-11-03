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
    ntfs-3g /dev/${disk1} /mnt/windows -o locale=1
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o locale failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o recover
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o recover failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o norecover
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o norecover failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o emove_hiberfile
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o emove_hiberfile failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o atime
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o atime failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o noatime
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o noatime failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o relatime
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o relatime failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o delay_mtime
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o delay_mtime failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o show_sys_files
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o show_sys_files failed."
    df -h | grep "/dev/${disk1}"
    CHECK_RESULT $? 0 0 "Check disk mount failed."
    umount /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows -o hide_hid_files
    CHECK_RESULT $? 0 0 "Check ntfs-3g -o hide_hid_files failed."
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
