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
# @Desc      :   verify the uasge of ntfscluster command
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
    ntfscluster --help 2>&1 | grep "Usage: ntfscluster \[options\]"
    CHECK_RESULT $? 0 0 "Check ntfscluster --help failed."
    ntfscluster --version 2>&1 | grep "ntfscluster v"
    CHECK_RESULT $? 0 0 "Check ntfscluster --version failed."
    ntfscluster --info /dev/${disk1} --force | grep "percentage metadata"
    CHECK_RESULT $? 0 0 "Check ntfscluster --info failed."
    ntfscluster --cluster 0-500 /dev/${disk1} --force | grep "Searching for cluster range 0-500"
    CHECK_RESULT $? 0 0 "Check ntfscluster --cluster failed." 
    ntfscluster --sector 0-500 /dev/${disk1} --force | grep "Searching for sector range 0-500"
    CHECK_RESULT $? 0 0 "Check ntfscluster --sector failed."
    ntfscluster --inode 5 /dev/${disk1} --force | grep "resident"
    CHECK_RESULT $? 0 0 "Check ntfscluster --inode failed."
    ntfscluster --filename test.txt /dev/${disk1} --force
    CHECK_RESULT $? 0 0 "Check ntfscluster --filename failed."
    ntfscluster --info /dev/${disk1} --force --quiet | grep "percentage metadata"
    CHECK_RESULT $? 0 0 "Check ntfscluster --quiet failed."
    ntfscluster --info /dev/${disk1} --force --verbose | grep "percentage metadata"
    CHECK_RESULT $? 0 0 "Check ntfscluster --verbose failed."
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
