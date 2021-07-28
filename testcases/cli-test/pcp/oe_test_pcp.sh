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
#@Date          :   2020-10-14
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pcp)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pcp --version | grep "$pcp_version"
    CHECK_RESULT $?
    pcp -a $archive_data -A 3min | grep 'Performance'
    CHECK_RESULT $?
    pcp -h $host_name | grep 'platform'
    CHECK_RESULT $?
    pcp -a $archive_data -O @08 -s 10 -t 2 | grep 'archive'
    CHECK_RESULT $?
    pcp -P | grep 'hardware'
    CHECK_RESULT $?
    pcp -a $archive_data -g | grep 'timezone'
    CHECK_RESULT $?
    pcp -a $archive_data -n /var/lib/pcp/pmns/root | grep 'services'
    CHECK_RESULT $?
    pcp -a $archive_data -p 22 | grep 'pmcd'
    CHECK_RESULT $?
    pcp -a $archive_data -S @08 -T @18 | grep "$archive_data"
    CHECK_RESULT $?
    pcp -Z Africa/Lagos | grep 'pmlogger'
    CHECK_RESULT $?
    pcp -a $archive_data -z | grep 'Performance Co-Pilot'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
