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
    nohup dstat --time-adv >/tmp/dstat_time-adv 2>&1 &
    SLEEP_WAIT 3 "grep 'time-adv' /tmp/dstat_time-adv" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat --epoch 5 >/tmp/dstat_epoch 2>&1 &
    SLEEP_WAIT 3 "grep 'epoch' /tmp/dstat_epoch" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -T 5 >/tmp/dstat_T 2>&1 &
    SLEEP_WAIT 3 "grep 'epoch' /tmp/dstat_T" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat --epoch-adv >/tmp/dstat_epoch-adv 2>&1 &
    SLEEP_WAIT 3 "grep 'epoch-adv' /tmp/dstat_epoch-adv" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat --vm-adv >/tmp/dstat_vm-adv 2>&1 &
    SLEEP_WAIT 3 "grep 'advanced-virtual-memory' /tmp/dstat_vm-adv" 2
    CHECK_RESULT $?
    kill -9 $!
    dstat --list | grep 'disk'
    CHECK_RESULT $?
    nohup dstat -a >/tmp/dstat_a 2>&1 &
    SLEEP_WAIT 3 "grep 'total-usage' /tmp/dstat_a" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -f >/tmp/dstat_f 2>&1 &
    SLEEP_WAIT 3 "grep 'usr' /tmp/dstat_f" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -v >/tmp/dstat_v 2>&1 &
    SLEEP_WAIT 3 "grep 'procs' /tmp/dstat_v" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -o file >/tmp/dstat_o 2>&1 &
    local_pid=$(echo $!)
    SLEEP_WAIT 3 "kill -9 $local_pid" 2
    CHECK_RESULT $?
    grep 'pcp-dstat' file
    CHECK_RESULT $?
    nohup dstat --profile >/tmp/dstat_profile 2>&1 &
    SLEEP_WAIT 3 "grep 'idl' /tmp/dstat_profile" 2
    CHECK_RESULT $?
    kill -9 $!
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f file /tmp/dstat_*
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
