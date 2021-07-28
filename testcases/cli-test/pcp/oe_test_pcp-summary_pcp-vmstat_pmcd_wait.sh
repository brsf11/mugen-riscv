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
#@Date          :   2020-10-23
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pcp-summary,pcp-vmstat,pmcd_wait)
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
    /usr/libexec/pcp/bin/pcp-summary -a $archive_data | grep 'Performance'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pcp-summary -D | grep 'log_archive'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pcp-summary -h $host_name | grep 'platform'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pcp-summary -a $archive_data -O @08 | grep 'archive'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pcp-summary -n /var/lib/pcp/pmns/root | grep 'hardware'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pcp-summary -P | grep 'timezone'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pcp-vmstat 1 10 | grep 'loadavg'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmcd_wait -h $host_name
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmcd_wait -t 30
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmcd_wait -v
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
