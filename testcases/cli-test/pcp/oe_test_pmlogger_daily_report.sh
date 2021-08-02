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
#@Date          :   2020-10-29
#@License       :   Mulan PSL v2
#@Desc          :   (pcp-zeroconf) pmlogger_daily_report - write Performance Co-Pilot daily summary reports
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    /usr/libexec/pcp/bin/pmlogger_daily_report -a yesterday
    CHECK_RESULT $?
    test -d /var/log/pcp/sa
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_daily_report -f momo.txt
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_daily_report -h $host_name
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_daily_report -l dailyReport.txt
    CHECK_RESULT $?
    grep 'pmlogger_daily_report' dailyReport.txt
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_daily_report -p
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_daily_report -o /var/log/pcp/ba/
    CHECK_RESULT $?
    test -d /var/log/pcp/ba
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_daily_report -t 30
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_daily_report -AV
    CHECK_RESULT $?
    grep "REPORTDIR=/var/log/pcp/sa" /var/log/pcp/pmlogger/pmlogger_daily_report.log
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /var/log/pcp/ba momo.txt dailyReport.txt
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
