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
#@Date          :   2020-10-19
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pmlogsummary)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    metric_name=disk.dev.write
    SLEEP_WAIT 60
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test." 
    pmlogsummary --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pmlogsummary -a $archive_data $metric_name | grep 'Log Label'
    CHECK_RESULT $?
    pmlogsummary -b $archive_data $metric_name | grep "$metric_name"
    CHECK_RESULT $?
    pmlogsummary -B 10 $archive_data $metric_name | grep "count / sec"
    CHECK_RESULT $?
    pmlogsummary -f $archive_data $metric_name | grep "count / sec"
    CHECK_RESULT $?
    pmlogsummary -F $archive_data $metric_name | grep "count / sec"
    CHECK_RESULT $?
    pmlogsummary -H $archive_data $metric_name | grep "time_average"
    CHECK_RESULT $?
    pmlogsummary -i $archive_data $metric_name | grep "$metric_name"
    CHECK_RESULT $?
    pmlogsummary -I $archive_data $metric_name | grep "count / sec"
    CHECK_RESULT $?
    pmlogsummary -l $archive_data $metric_name | grep 'Performance metrics'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
