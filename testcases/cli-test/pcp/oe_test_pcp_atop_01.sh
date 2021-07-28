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
#@Date          :   2020-10-28
#@License       :   Mulan PSL v2
#@Desc          :   (pcp-system-tools) (pcp-atop)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    DNF_INSTALL pcp-system-tools
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    /usr/libexec/pcp/bin/pcp-atop -V | grep 'version'
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -aRfFGl1xgnC -L 80 >atop_a 2>&1 &
    SLEEP_WAIT 7 
    grep 'SYSCPU' atop_a
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -P CPU >atop_P 2>&1 &
    SLEEP_WAIT 7 
    grep 'SEP' atop_P
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -y >atop_y 2>&1 &
    SLEEP_WAIT 7 
    grep 'TID' atop_y
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -m >atop_m 2>&1 &
    SLEEP_WAIT 7
    grep 'VSIZE' atop_m
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -d >atop_d 2>&1 &
    SLEEP_WAIT 7
    grep 'WCANCL' atop_d
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -s >atop_s 2>&1 &
    SLEEP_WAIT 7
    grep 'TRUN' atop_s
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -v >atop_v 2>&1 &
    SLEEP_WAIT 7
    grep 'PPID' atop_v
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -c >atop_c 2>&1 &
    SLEEP_WAIT 7
    grep 'COMMAND-LINE' atop_c
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f atop*
    kill -9 $(pgrep -f /usr/libexec/pcp/bin/pcp-atop)
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
