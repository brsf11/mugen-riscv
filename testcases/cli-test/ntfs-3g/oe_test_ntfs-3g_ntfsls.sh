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
# @Desc      :   verify the uasge of ntfsls command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    mkdir -p /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows
    mkdir /mnt/windows/test
    touch {/mnt/windows/test/test1.txt,/mnt/windows/test/test2.py}
    umount /mnt/windows
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfsls --help 2>&1 | grep "Usage: ntfsls \[options\]"
    CHECK_RESULT $? 0 0 "Check ntfsls --help failed."
    ntfsls --version 2>&1 | grep "ntfsls v"
    CHECK_RESULT $? 0 0 "Check ntfsls --version failed."
    ntfsls /dev/${disk1} --all | grep "test"
    CHECK_RESULT $? 0 0 "Check ntfsls --all failed."
    ntfsls /dev/${disk1} --classify | grep "test\/"
    CHECK_RESULT $? 0 0 "Check ntfsls --classify failed."
    ntfsls /dev/${disk1} --force | grep "test"
    CHECK_RESULT $? 0 0 "Check ntfsls --force failed."
    ntfsls /dev/${disk1} --inode | grep "test"
    CHECK_RESULT $? 0 0 "Check ntfsls --inode failed."
    ntfsls /dev/${disk1} --long | grep "test"
    CHECK_RESULT $? 0 0 "Check ntfsls --long failed."
    ntfsls /dev/${disk1} --path test | grep "test" 
    CHECK_RESULT $? 0 0 "Check ntfsls --path failed."
    ntfsls /dev/${disk1} --quiet --path test | grep "test"
    CHECK_RESULT $? 0 0 "Check ntfsls --quiet failed."
    ntfsls /dev/${disk1} --recursive | grep "test"
    CHECK_RESULT $? 0 0 "Check ntfsls --recursive failed."
    ntfsls /dev/${disk1} --system | grep "Volume"
    CHECK_RESULT $? 0 0 "Check ntfsls --system failed."
    ntfsls /dev/${disk1} --dos --path test | grep "test"
    CHECK_RESULT $? 0 0 "Check ntfsls --dos --path failed."
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
