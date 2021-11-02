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
# @Desc      :   verify the uasge of ntfsresize command
# ############################################

source "common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    get_disk
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ntfsresize --help 2>&1 | grep "Usage: ntfsresize \[OPTIONS\]"
    CHECK_RESULT $? 0 0 "Check ntfsresize --help failed."
    ntfsresize --version 2>&1 | grep "ntfsresize v"
    CHECK_RESULT $? 0 0 "Check ntfsresize --version failed."
    ntfsresize --check /dev/${disk1} | grep "ntfsresize"
    CHECK_RESULT $? 0 0 "Check ntfsresize --check failed."
    ntfsresize --info /dev/${disk1} | grep "Device name"
    CHECK_RESULT $? 0 0 "Check ntfsresize --info failed."
    ntfsresize --info-mb-only /dev/${disk1} | grep "Minsize"
    CHECK_RESULT $? 0 0 "Check ntfsresize --info-mb-only failed."
    expect <<EOF
    spawn ntfsresize --size 5G /dev/${disk1}
    expect "Are you sure you want to proceed*"
    send "y\n"
    expect eof
EOF
    CHECK_RESULT $? 0 0 "Check ntfsresize --size failed."
    ntfsresize --expand /dev/${disk1} | grep "ntfsresize"
    CHECK_RESULT $? 0 0 "Check ntfsresize --expand failed."
    ntfsresize --no-action /dev/${disk1} --force | grep "Device name"
    CHECK_RESULT $? 0 0 "Check ntfsresize --no-action failed."
    expect <<EOF
    spawn ntfsresize --bad-sectors /dev/${disk1} --force
    expect "Are you sure you want to proceed*"
    send "y\n"
    expect eof
EOF
    CHECK_RESULT $? 0 0 "Check ntfsresize --bad-sectors failed."
    ntfsresize --no-progress-bar /dev/${disk1} --force | grep "Device name"
    CHECK_RESULT $? 0 0 "Check ntfsresize --no-progress-bar failed."
    ntfsresize --verbose /dev/${disk1} --force | grep "Device name"
    CHECK_RESULT $? 0 0 "Check ntfsresize --verbose failed."
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
