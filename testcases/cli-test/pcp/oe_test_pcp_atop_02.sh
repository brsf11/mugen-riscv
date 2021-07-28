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
    nohup /usr/libexec/pcp/bin/pcp-atop -o >atop_o 2>&1 &
    SLEEP_WAIT 7
    grep 'procacct' atop_o
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -u >atop_u 2>&1 &
    SLEEP_WAIT 7
    grep 'RUID' atop_u
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -p >atop_p 2>&1 &
    SLEEP_WAIT 7
    grep 'SNET' atop_p
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -j >atop_j 2>&1 &
    SLEEP_WAIT 7
    grep 'CID' atop_j
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -M >atop_M 2>&1 &
    SLEEP_WAIT 2
    test -f atop_M
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -D >atop_D 2>&1 &
    SLEEP_WAIT 7
    grep 'DSK' atop_D
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -N >atop_N 2>&1 &
    SLEEP_WAIT 7
    grep 'NET' atop_N
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -A >atop_A 2>&1 &
    SLEEP_WAIT 30
    grep 'ACPU' atop_A
    CHECK_RESULT $?
    nohup /usr/libexec/pcp/bin/pcp-atop -w testdir -S -a >atop_wSa 2>&1 &
    SLEEP_WAIT 2
    test -d testdir
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf ./testdir atop*
    kill -9 $(pgrep -f /usr/libexec/pcp/bin/pcp-atop)
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
