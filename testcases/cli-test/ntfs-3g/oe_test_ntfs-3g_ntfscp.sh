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
# @Desc      :   verify the uasge of ntfscp command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    dir=/mnt/windows
    file=test.txt
    mkdir -p ${dir}
    touch ${file}
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfscp --help 2>&1 | grep "Usage: ntfscp \[options\]"
    CHECK_RESULT $? 0 0 "Check ntfscp --help failed."
    ntfscp --version 2>&1 | grep "ntfscp v"
    CHECK_RESULT $? 0 0 "Check ntfscp --version failed."
    ntfscp /dev/${disk1} ${file} ${file} --attribute 256
    CHECK_RESULT $? 0 0 "Check ntfscp --attribute failed."
    check_file_and_umount_disk ${disk1} ${dir} ${file}
    ntfscp /dev/${disk1} ${file} ${file} --attr-name stream
    CHECK_RESULT $? 0 0 "Check ntfscp --attr-name failed."
    check_file_and_umount_disk ${disk1} ${dir} ${file}
    ntfscp /dev/${disk1} ${file} ${file} --no-action
    CHECK_RESULT $? 0 0 "Check ntfscp --no-action failed."
    ntfscp /dev/${disk1} ${file} ${file} --force
    CHECK_RESULT $? 0 0 "Check ntfscp --force failed."
    check_file_and_umount_disk ${disk1} ${dir} ${file}
    ntfscp /dev/${disk1} ${file} ${file} --quiet
    CHECK_RESULT $? 0 0 "Check ntfscp --quiet failed."
    check_file_and_umount_disk ${disk1} ${dir} ${file}
    ntfscp /dev/${disk1} ${file} ${file} --verbose
    CHECK_RESULT $? 0 0 "Check ntfscp --verbose failed."
    check_file_and_umount_disk ${disk1} ${dir} ${file}
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    expect <<EOF
    spawn mkfs.ext4 /dev/${disk1}
    send "y\n"
    expect eof
EOF
    rm -rf ${dir} ${file}
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
