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
#@Date          :   2020-10-15
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pmevent)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    metric_name=disk.dev.write
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pmevent --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pmevent -a $archive_data -A 3min $metric_name | grep 'metric'
    CHECK_RESULT $?
    pmevent -h $host_name -s 10 $metric_name | grep "$metric_name"
    CHECK_RESULT $?
    pmevent -n /var/lib/pcp/pmns/root -s 10 $metric_name | grep 'semantics'
    CHECK_RESULT $?
    pmevent -a $archive_data -O @08 -s 10 -t 2 $metric_name | grep "$archive_data"
    CHECK_RESULT $?
    pmevent -a $archive_data -S @08 -T @18 -s 10 $metric_name | grep 'units'
    CHECK_RESULT $?
    pmevent -Z Africa/Lagos -s 10 $metric_name | grep 'TZ=Africa/Lagos'
    CHECK_RESULT $?
    pmevent -z -s 10 $metric_name | grep 'local timezone'
    CHECK_RESULT $?
    pmevent -K del,60 -s 10 $metric_name | grep 'samples'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
