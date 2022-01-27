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
#@Desc          :   (pcp-system-tools) (pcp-dstat)
#####################################

source "common/common_pcp-system-tools.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    dstat --help 2>&1 | grep 'Usage'
    CHECK_RESULT $?
    dstat --version | grep "$pcp_version"
    CHECK_RESULT $?
    nohup dstat -cdglmn --color >/tmp/dstat_color 2>&1 &
    SLEEP_WAIT 3 "grep \"total-usage\" /tmp/dstat_color" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -cdglmn --nocolor >/tmp/dstat_nocolor 2>&1 &
    SLEEP_WAIT 3 "grep 'dsk/total' /tmp/dstat_nocolor" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -cdglmn --bw >/tmp/dstat_bw 2>&1 &
    SLEEP_WAIT 3 "grep 'paging' /tmp/dstat_bw" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -cdglmn --bits >/tmp/dstat_bits 2>&1 &
    SLEEP_WAIT 3 "grep 'load-avg' /tmp/dstat_bits" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -cdglmn --float >/tmp/dstat_float 2>&1 &
    SLEEP_WAIT 3 "grep 'memory-usage' /tmp/dstat_float" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -cdglmn --integer >/tmp/dstat_integer 2>&1 &
    SLEEP_WAIT 3 "grep 'net/total' /tmp/dstat_integer" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -tprsy >/tmp/dstat_tprsy 2>&1 &
    SLEEP_WAIT 3 "grep 'time' /tmp/dstat_tprsy" 2
    CHECK_RESULT $?
    kill -9 $!
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    rm -f /tmp/dstat_*
    LOG_INFO "End to restore the test environment."
}

main "$@"
