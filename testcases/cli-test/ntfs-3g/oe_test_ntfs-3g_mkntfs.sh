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
# @Desc      :   verify the uasge of mkntfs command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mkntfs --help 2>&1 | grep "Usage: mkntfs \[options\]"
    CHECK_RESULT $? 0 0 "Check mkntfs --help failed."
    mkntfs --version 2>&1 | grep "mkntfs v"
    CHECK_RESULT $? 0 0 "Check mkntfs --version failed."
    mkntfs --fast /dev/${disk1} | grep "mkntfs completed successfully"
    CHECK_RESULT $? 0 0 "Check mkntfs --fast failed."
    mkntfs --quick /dev/${disk1} | grep "mkntfs completed successfully"
    CHECK_RESULT $? 0 0 "Check mkntfs --quick failed."
    mkntfs --label 5 /dev/${disk1} | grep "mkntfs completed successfully"
    CHECK_RESULT $? 0 0 "Check mkntfs --label failed."
    mkntfs --enable-compression /dev/${disk1} | grep "mkntfs completed successfully"
    CHECK_RESULT $? 0 0 "Check mkntfs --enable-compression failed."
    mkntfs --no-indexing /dev/${disk1} | grep "mkntfs completed successfully"
    CHECK_RESULT $? 0 0 "Check mkntfs --no-indexing failed."
    mkntfs --no-action /dev/${disk1} | grep "Running in READ-ONLY mode"
    CHECK_RESULT $? 0 0 "Check mkntfs --no-action failed."
    mkntfs --fast /dev/${disk1} --cluster-size 512 --sector-size 256 --partition-start 256 --heads 10 --sectors-per-track 16 --mft-zone-multiplier 10 --zero-time --force | grep "mkntfs completed successfully"
    CHECK_RESULT $? 0 0 "Check mkntfs --cluster-size --sector-size --partition-start --heads --sectors-per-track --mft-zone-multiplier --zero-time --force failed."
    mkntfs --fast /dev/${disk1} --quiet
    CHECK_RESULT $? 0 0 "Check mkntfs --quiet failed."
    mkntfs --fast /dev/${disk1} --verbose | grep "mkntfs completed successfully"
    CHECK_RESULT $? 0 0 "Check mkntfs --verbose failed."
    mkntfs --fast /dev/${disk1} --license | grep "This program"
    CHECK_RESULT $? 0 0 "Check mkntfs --license failed."
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    expect <<EOF
    spawn mkfs.ext4 /dev/${disk1}
    send "y\n"
    expect eof
EOF
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
