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
#@Date          :   2020-10-26
#@License       :   Mulan PSL v2
#@Desc          :   (pcp-system-tools) (pmrep)
#####################################

source "common/common_pcp-system-tools.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    metric_name=disk.dev.write
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pmrep -a $archive_data $metric_name -o stdout | grep 'count/s'
    CHECK_RESULT $?
    pmrep -a $archive_data $metric_name -F OUTFILE
    CHECK_RESULT $?
    grep 'count/s' OUTFILE
    CHECK_RESULT $?
    pmrep --daemonize -s 10 $metric_name | grep 'count/s'
    CHECK_RESULT $?
    pmrep -H -s 10 $metric_name | grep 'N/A'
    CHECK_RESULT $?
    pmrep -U -s 10 $metric_name | grep 'd.d.write'
    CHECK_RESULT $?
    pmrep -G -s 10 $metric_name | grep 'count/s'
    CHECK_RESULT $?
    pmrep -p -s 10 $metric_name | grep 'count/s'
    CHECK_RESULT $?
    pmrep -a $archive_data -S @08 -T @18 $metric_name | grep 'count/s'
    CHECK_RESULT $?
    pmrep -a $archive_data -O @08 -s 10 -t 2 $metric_name | grep 'count/s'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f OUTFILE
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
