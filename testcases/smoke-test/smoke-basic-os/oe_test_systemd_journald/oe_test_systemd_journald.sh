#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/06/16
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of journalctl
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    journalctl -f >testlog &
    CHECK_RESULT $? 0 0 "Failed to execute journalctl -f"
    SLEEP_WAIT 3
    grep -E "begins at|begin at" testlog
    CHECK_RESULT $? 0 0 "Failed to find begin"
    kill -9 $(pgrep journalctl)
    journalctl --reverse --lines 10 --no-pager | grep -vE "begins at|begin at" | wc -l | grep 10
    CHECK_RESULT $? 0 0 "Failed to execute journalctl --lines"
    journalctl --show-cursor | grep cursor
    CHECK_RESULT $? 0 0 "Failed to execute journalctl -show-cursor"
    mkdir /tmp/log
    cp /run/log/journal/*/system.journal /tmp/log
    journalctl --directory /tmp/log/ --rotate --vacuum-size=8M
    CHECK_RESULT $? 0 0 "Failed to execute journalctl --directory"
    journalctl /usr/lib/systemd/systemd
    CHECK_RESULT $? 0 0 "Failed to execute journalctl"
    journalctl /usr/lib/systemd/systemd1
    CHECK_RESULT $? 0 1 "Succeed to execute journalctl"
    local_disk=$(lsblk | grep disk | grep da | head -n 1 | awk '{print $1}')
    journalctl /dev/$local_disk | grep -E "begins at|begin at"
    CHECK_RESULT $? 0 0 "Failed to execute journalctl disk"
    journalctl /dev/testdev
    CHECK_RESULT $? 0 1 "Succeed to execute journalctl disk"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/log testlog
    LOG_INFO "End to restore the test environment."
}

main "$@"
