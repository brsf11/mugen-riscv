#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-10-27
#@License       :   Mulan PSL v2
#@Desc          :   (pcp-system-tools) (pcp-pidstat)
#####################################

source "common/common_pcp-system-tools.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    OLD_PATH=$PATH
    export PATH=/usr/libexec/pcp/bin/:$PATH
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    SLEEP_WAIT 60
    pcp-pidstat --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pcp-pidstat -a $archive_data -s 10 | grep 'UID'
    CHECK_RESULT $?
    pcp-pidstat -t 2 -s 3 -I -U pcp -G pmcd | grep 'pmcd'
    CHECK_RESULT $?
    pid=$(pcp-pidstat -s 2 -U pcp -G pmcd | grep pmcd | awk '{print $3}')
    CHECK_RESULT $?
    pcp-pidstat -t 2 -s 3 -I -U pcp -p $pid | grep 'UName'
    CHECK_RESULT $?
    pcp-pidstat -s 2 -p $pid -f %s | grep 'PID'
    CHECK_RESULT $?
    pcp-pidstat -s 2 -p $pid -B all | grep 'State'
    CHECK_RESULT $?
    pcp-pidstat -s 2 -p $pid -B detail | grep 'R'
    CHECK_RESULT $?
    pcp-pidstat -s 2 -p $pid -l | grep 'guest'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    PATH=${OLD_PATH}
    LOG_INFO "End to restore the test environment."
}

main "$@"
