#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
#@Date          :   2020-10-26
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pmlogreduce,pmpause,pmpost,pmsleep)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    /usr/libexec/pcp/bin/pmlogreduce -A 10min -v 10 $archive_data /var/log/pcp/pmlogger/$(hostname)/$(date +%Y%m%d-%H%M)
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogreduce -S @08 -T @18 -s 10 -t 2 $archive_data /var/log/pcp/pmlogger/$(hostname)/$(date +%Y%m%d-%H%M%S)
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogreduce -Z Africa/Sao_Tome $archive_data /var/log/pcp/pmlogger/$(hostname)/$(date +%Y%m%d-%H%M) | grep 'TZ=Africa/Sao_Tome'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogreduce -z $archive_data /var/log/pcp/pmlogger/$(hostname)/$(date +%Y%m%d-%H%M) | grep 'local timezone'
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pmpause &
    ps aux | grep pmpause | grep -v grep | awk '{print $8}' | grep 'S'
    CHECK_RESULT $?
    kill -9 $(pgrep -f /usr/libexec/pcp/bin/pmpause)
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmpost pmpost_info
    CHECK_RESULT $?
    grep 'pmpost_info' /var/log/pcp/NOTICES
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmsleep 3
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f /var/log/pcp/NOTICES
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
