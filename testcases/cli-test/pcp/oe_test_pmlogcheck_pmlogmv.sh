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
#@Desc          :   pcp testing(pmlogcheck,pmlogmv)
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
    pmlogcheck -l $archive_data 2>&1 | grep 'Log Label'
    CHECK_RESULT $?
    pmlogcheck -n /var/lib/pcp/pmns/root $archive_data 2>&1 | grep 'PMID'
    CHECK_RESULT $?
    pmlogcheck -S @00 -T @23 $archive_data
    CHECK_RESULT $?
    pmlogcheck -v $archive_data 2>&1 | grep 'meta'
    CHECK_RESULT $?
    pmlogcheck -w $archive_data
    CHECK_RESULT $?
    pmlogcheck -Z Africa/Sao_Tome $archive_data | grep 'TZ=Africa/Sao_Tome'
    CHECK_RESULT $?
    pmlogcheck -z $archive_data | grep 'local timezone'
    CHECK_RESULT $?
    pmlogmv -NV $archive_data /var/log/pcp/pmlogger_new/$host_name/ 2>&1 | grep 'link'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f pmlogcheck_*.log
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
