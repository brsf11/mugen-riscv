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
#@Date          :   2020-10-28
#@License       :   Mulan PSL v2
#@Desc          :   (pcp-system-tools) (pcp-mpstat,pcp-numastat)
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
    pcp-mpstat --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pcp-mpstat -a $archive_data -s 10 -t 2 | grep 'CPU'
    CHECK_RESULT $?
    pcp-mpstat -a $archive_data -u -s 10 | grep '%usr'
    CHECK_RESULT $?
    pcp-mpstat -a $archive_data -A -s 10 | grep '%nice'
    CHECK_RESULT $?
    pcp-mpstat -a $archive_data -P ON -s 10 | grep '%sys'
    CHECK_RESULT $?
    pcp-mpstat -a $archive_data -I SUM -s 10 | grep 'intr/s'
    CHECK_RESULT $?
    pcp-numastat --help 2>&1 | grep 'Usage'
    CHECK_RESULT $?
    pcp-numastat --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pcp-numastat -w 3 | grep 'node0'
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
