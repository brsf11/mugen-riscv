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
# @Desc      :   verify the uasge of ntfsundelete command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    mkdir -p /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows
    touch /mnt/windows/test.txt
    rm -rf /mnt/windows/test.txt
    umount /mnt/windows
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfsundelete --help 2>&1 | grep "Usage: ntfsundelete \[options\]"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --help failed."
    ntfsundelete --version 2>&1 | grep "ntfsundelete v"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --version failed."
    ntfsundelete --scan /dev/${disk1} --force | grep "test.txt"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --scan failed."
    ntfsundelete --percentage 10 /dev/${disk1} --force | grep "test.txt"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --percentage failed."
    ntfsundelete --match test.txt /dev/${disk1} --force | grep "test.txt"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --match failed."
    ntfsundelete --case --match test.txt /dev/${disk1} --force | grep "test.txt"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --case failed."
    ntfsundelete --size 0 /dev/${disk1} --force | grep "test.txt"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --size failed."
    ntfsundelete --time 2021y /dev/${disk1} --force | grep "test.txt"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --time failed."
    ntfsundelete --undelete --match test.txt /dev/${disk1} --force | grep "Undeleted 'test.txt' successfully to test.txt"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --undelete failed."
    ntfsundelete --inode 7 /dev/${disk1} --force | grep "test.txt"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --inode failed."
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    expect <<EOF
    spawn mkfs.ext4 /dev/${disk1}
    send "y\n"
    expect eof
EOF
    rm -rf /mnt/windows test.txt*
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
