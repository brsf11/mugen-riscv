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
# @Desc      :   verify the uasge of ntfssecaudit command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    mkdir -p /mnt/windows
    ntfs-3g /dev/${disk1} /mnt/windows
    mkdir /mnt/windows/test
    touch {test.txt,/mnt/windows/test.txt,/mnt/windows/test/a.txt}
    umount /mnt/windows
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfssecaudit --help 2>&1 | grep "Usage:"
    CHECK_RESULT $? 0 0 "Check ntfssecaudit --help failed."
    ntfssecaudit --version 2>&1 | grep "ntfssecaudit v"
    CHECK_RESULT $? 0 0 "Check ntfssecaudit --version failed."
    ntfssecaudit -t | grep "No errors were found"
    CHECK_RESULT $? 0 0 "Check ntfssecaudit -t failed."
    ntfssecaudit -h test.txt | grep "No errors were found"
    CHECK_RESULT $? 0 0 "Check ntfssecaudit -h failed."
    ntfssecaudit -arv /dev/${disk1} | grep "No errors were found"
    CHECK_RESULT $? 0 0 "Check ntfssecaudit -arv failed."
    ntfssecaudit -v /dev/${disk1} test.txt | grep "No errors were found"
    CHECK_RESULT $? 0 0 "Check ntfssecaudit -v failed."
    ntfssecaudit -rv /dev/${disk1} test | grep "No errors were found"
    CHECK_RESULT $? 0 0 "Check ntfssecaudit -rv failed."
    ntfssecaudit -bv /dev/${disk1} test | grep "No errors were found"
    CHECK_RESULT $? 0 0 "Check ntfssecaudit -bv failed."
    ntfssecaudit -sev /dev/${disk1} test.txt | grep "No errors were found"
    CHECK_RESULT $? 0 0 "Check ntfssecaudit -sev failed."
    ntfssecaudit /dev/${disk1} 777 test.txt | grep "No errors were found"
    CHECK_RESULT $? 0 0 "Check ntfssecaudit perms file failed."
    ntfssecaudit -rv /dev/${disk1} 777 test | grep "No errors were found"
    CHECK_RESULT $? 0 0 "Check ntfssecaudit perms directory failed."
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    expect <<EOF
    spawn mkfs.ext4 /dev/${disk1}
    send "y\n"
    expect eof
EOF
    rm -rf /mnt/windows test.txt
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
