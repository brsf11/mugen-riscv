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
#@Date          :   2020-10-29
#@License       :   Mulan PSL v2
#@Desc          :   (pcp-export-pcp2xml) pcp2xml - pcp-to-xml metrics exporter
#####################################

source "common/common_pcp2xml.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pcp2xml -v -s 10 -t 2 $metric_name | grep 'metrics'
    CHECK_RESULT $?
    pcp2xml -f STR -s 10 -t 2 $metric_name | grep 'metrics'
    CHECK_RESULT $?
    pcp2xml -P 3 -s 10 -t 2 $metric_name | grep 'metrics'
    CHECK_RESULT $?
    pcp2xml -0 3 -s 10 -t 2 $metric_name | grep 'metrics'
    CHECK_RESULT $?
    pcp2xml -q 100 -s 10 -t 2 kernel.all.load | grep 'metrics'
    CHECK_RESULT $?
    pcp2xml -Q 100 -s 10 -t 2 kernel.all.load | grep 'metrics'
    CHECK_RESULT $?
    pcp2xml -b MB -s 10 -t 2 $metric_name | grep 'metrics'
    CHECK_RESULT $?
    pcp2xml -B MB -s 10 -t 2 $metric_name | grep 'metrics'
    CHECK_RESULT $?
    pcp2xml -y s -s 10 -t 2 $metric_name | grep 'metrics'
    CHECK_RESULT $?
    pcp2xml -Y s -s 10 -t 2 $metric_name | grep 'metrics'
    CHECK_RESULT $?
    pcp2xml -x -s 10 -t 2 $metric_name | grep 'metrics'
    CHECK_RESULT $?
    pcp2xml -X -s 10 -t 2 $metric_name | grep 'metrics'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
