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
#@Desc          :   pcp testing(pminfo)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    metric_name=disk.dev.write
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pminfo -I $metric_name | grep 'Data Type'
    CHECK_RESULT $?
    pminfo -l $metric_name | grep 'labels'
    CHECK_RESULT $?
    pminfo -m $metric_name | grep 'PMID'
    CHECK_RESULT $?
    pminfo -M $metric_name | grep 'PMID'
    CHECK_RESULT $?
    pminfo -s $metric_name | grep 'Source'
    CHECK_RESULT $?
    pminfo -t $metric_name | grep "per-disk"
    CHECK_RESULT $?
    pminfo -T $metric_name | grep "$metric_name"
    CHECK_RESULT $?
    pminfo -c /var/lib/pcp/config/pmieconf/dm $metric_name | grep "$metric_name"
    CHECK_RESULT $?
    pminfo -x $metric_name | grep "$metric_name"
    CHECK_RESULT $?
    pminfo -v $metric_name
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
