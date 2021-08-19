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
#@Desc          :   pcp testing(pmstat)
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
    pmstat -a $archive_data -A 5min -s 10 | grep 'loadavg'
    CHECK_RESULT $?
    pmstat -h $host_name -s 10 -t 2 | grep 'memory'
    CHECK_RESULT $?
    pmstat -n /var/lib/pcp/pmns/root -s 3 | grep 'swap'
    CHECK_RESULT $?
    pmstat -a $archive_data -O @08 -s 10 | grep 'io'
    CHECK_RESULT $?
    pmstat -a $archive_data -S @08 -T @18 -s 10 | grep 'system'
    CHECK_RESULT $?
    pmstat -Z Africa/Sao_Tome -s 3 | grep 'TZ=Africa/Sao_Tome'
    CHECK_RESULT $?
    pmstat -a $archive_data -z -s 3 | grep 'local timezone'
    CHECK_RESULT $?
    pmstat -L -s 3 | grep 'cpu'
    CHECK_RESULT $?
    pmstat -l -s 3 | grep 'swpd'
    CHECK_RESULT $?
    pmstat -a $archive_data -P -s 3 | grep 'free'
    CHECK_RESULT $?
    pmstat -x -s 3 | grep 'buff'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
