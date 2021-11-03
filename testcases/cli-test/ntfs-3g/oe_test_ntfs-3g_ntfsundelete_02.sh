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
    ntfsundelete /dev/${disk1} --copy 5-7 --output debug --force | grep "MFT extracted to file debug"
    CHECK_RESULT $? 0 0 "Check ntfsundelete -output failed."
    ntfsundelete --optimistic /dev/${disk1} --force | grep "test.txt"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --optimistic failed."
    ntfsundelete /dev/${disk1} -c 5-7 --destination ./ --force | grep "MFT extracted to file"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --destination failed."
    ntfsundelete --undelete --byte 3 --match test.txt /dev/${disk1} --force | grep "Undeleted 'test.txt' successfully to test.txt"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --byte failed."
    ntfsundelete --undelete --truncate --match test.txt /dev/${disk1} --force | grep "Undeleted 'test.txt' successfully to test.txt"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --truncate failed."
    ntfsundelete --parent --verbose /dev/${disk1} --force | grep "Files with potentially recoverable content"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --parent failed."
    ntfsundelete /dev/${disk1} --copy 5-7 -o debug --force | grep "MFT extracted to file debug"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --copy failed."
    rm -rf test.txt*
    ntfsundelete --undelete --quiet --match test.txt /dev/${disk1} --force
    CHECK_RESULT $? 0 0 "Check ntfsundelete --quiet failed."
    test -f test.txt
    CHECK_RESULT $? 0 0 "Check file failed."
    ntfsundelete --verbose /dev/${disk1} --force | grep "Files with potentially recoverable content"
    CHECK_RESULT $? 0 0 "Check ntfsundelete --verbose failed."
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    expect <<EOF
    spawn mkfs.ext4 /dev/${disk1}
    send "y\n"
    expect eof
EOF
    rm -rf /mnt/windows test.txt* mft debug*
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
