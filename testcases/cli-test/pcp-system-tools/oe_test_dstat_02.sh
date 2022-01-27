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
    disk_name=$(lsblk | grep 'disk' | awk '{print $1}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    nohup dstat -tprsy --noheaders >/tmp/dstat_noheaders 2>&1 &
    SLEEP_WAIT 3 "grep 'system' /tmp/dstat_noheaders" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -tprsy --noupdate >/tmp/dstat_noupdate 2>&1 &
    SLEEP_WAIT 3 "grep 'procs' /tmp/dstat_noupdate" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat --aio --fs --ipc --lock --raw --socket --tcp --udp --unix --vm >/tmp/dstat_aio 2>&1 &
    SLEEP_WAIT 3 "grep 'async' /tmp/dstat_aio" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -C 0,3,total >/tmp/dstat_C 2>&1 &
    SLEEP_WAIT 3 "grep 'cpu0-usage' /tmp/dstat_C" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -D total,${disk_name} >/tmp/dstat_D 2>&1 &
    SLEEP_WAIT 3 "grep "dsk/${disk_name}" /tmp/dstat_D" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -i >/tmp/dstat_i 2>&1 &
    SLEEP_WAIT 3 "test -f /tmp/dstat_i" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -I 9,CAL >/tmp/dstat_I 2>&1 &
    SLEEP_WAIT 3 "grep 'total-usage' /tmp/dstat_I" 2
    CHECK_RESULT $?
    kill -9 $! 
    nohup dstat -N ${NODE1_NIC} >/tmp/dstat_N 2>&1 &
    SLEEP_WAIT 3 "grep "net/${NODE1_NIC}" /tmp/dstat_N" 2
    CHECK_RESULT $?
    kill -9 $!
    nohup dstat -S swap1,total >/tmp/dstat_S 2>&1 &
    SLEEP_WAIT 3 "grep 'paging' /tmp/dstat_S" 2
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
