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
#@Date          :   2020-10-26
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pmlogger_merge,pmlogger_rewrite)
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
    /usr/libexec/pcp/bin/pmlogger_merge -f
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_merge -N
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_merge -V
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_rewrite -c /etc/pcp.conf $archive_data
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_rewrite -d $archive_data
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_rewrite -N $archive_data | grep 'pmlogrewrite'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_rewrite -s $archive_data
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_rewrite -V ${archive_data}.index
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_rewrite -v $archive_data
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pmlogger_rewrite -w $archive_data
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
