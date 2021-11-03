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
# @Desc      :   verify the uasge of ntfsfallocate command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    mkdir -p /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows
    touch /mnt/windows/database.db
    umount /mnt/windows
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfsfallocate -h 2>&1 | grep "Usage: ntfsfallocate \[options\]"
    CHECK_RESULT $? 0 0 "Check ntfsfallocate -h failed."
    ntfsfallocate -V 2>&1 | grep "ntfsfallocate v"
    CHECK_RESULT $? 0 0 "Check ntfsfallocate -V failed."
    ntfsfallocate -l 100M /dev/${disk1} database.db | grep "ntfsfallocate completed successfully"
    CHECK_RESULT $? 0 0 "Check ntfsfallocate -l failed."
    ntfsfallocate -l 101M /dev/${disk1} database.db -f | grep "ntfsfallocate completed successfully"
    CHECK_RESULT $? 0 0 "Check ntfsfallocate -f failed."
    ntfsfallocate -l 102M /dev/${disk1} database.db -n | grep "ntfsfallocate completed successfully"
    CHECK_RESULT $? 0 0 "Check ntfsfallocate -n failed."
    ntfsfallocate -l 103M /dev/${disk1} database.db -o 1 | grep "ntfsfallocate completed successfully"
    CHECK_RESULT $? 0 0 "Check ntfsfallocate -o failed."
    ntfsfallocate -l 104M /dev/${disk1} database.db -v | grep "ntfsfallocate completed successfully"
    CHECK_RESULT $? 0 0 "Check ntfsfallocate -v failed."
    ntfsfallocate -l 105M /dev/${disk1} database.db -vv | grep "ntfsfallocate completed successfully"
    CHECK_RESULT $? 0 0 "Check ntfsfallocate -vv failed."
    ntfsfallocate -l 106M /dev/${disk1} database.db 256 | grep "ntfsfallocate completed successfully"
    CHECK_RESULT $? 0 0 "Check ntfsfallocate attr-name failed."
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
