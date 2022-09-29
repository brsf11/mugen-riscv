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
# @Date      :   2022/06/22
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "at bc"
    systemctl start atd
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    date +%M >/tmp/timelog1
    expect <<EOF
        spawn at now+1 minutes
        expect "at>" { send "date +%M >/tmp/timelog2\r" }
        expect "at>" { send "\04" }
        expect eof
EOF
    SLEEP_WAIT 60
    echo "$(cat /tmp/timelog1)-$(cat /tmp/timelog2)" | bc | grep 1
    CHECK_RESULT $? 0 0 "Failed to execute at"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/timelog*
    systemctl stop atd
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
