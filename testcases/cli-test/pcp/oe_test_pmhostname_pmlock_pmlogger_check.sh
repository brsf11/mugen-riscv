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
#@Date          :   2020-10-23
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pmhostname,pmlock,pmlogger_check)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    /usr/libexec/pcp/bin/pmhostname $host_name | grep "$host_name\|localhost"
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlock -v mu.txt
    CHECK_RESULT $?
    test -r mu.txt -o -w mu.txt -o -x mu.txt
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_check -c /etc/pcp/pmlogger/control.d/local
    CHECK_RESULT $?
    test -n $(pgrep -f /usr/libexec/pcp/bin/pmlogger)
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_check -l /var/log/pcp/pmlogger/pmlogger_check.log
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_check -C
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_check -NT | grep "get mutex lock"
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_check -NV | grep "compressing PCP archives for host local:"
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_check -s
    CHECK_RESULT $?
    test -z $(pgrep -f /usr/libexec/pcp/bin/pmlogger)
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f mu.txt
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
