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
#@Desc          :   (pcp-export-pcp2json) pcp2json - pcp-to-json metrics exporter
#####################################

source "common/common_pcp2json.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pcp2json --version 2>&1 | grep 'version'
    CHECK_RESULT $?
    pcp2json -a $archive_data -A 10min -s 10 $metric_name | grep 'archived metrics'
    CHECK_RESULT $?
    pcp2json --archive-folio=/var/log/pcp/pmlogger/$(hostname)/Latest -s 10 $metric_name | grep 'archived metrics'
    CHECK_RESULT $?
    pcp2json --container=busybox -s 10 -t 2 vfs.inodes.count | grep '@metrics'
    CHECK_RESULT $?
    pcp2json -h $host_name -s 10 -t 2 $metric_name | grep '@interval'
    CHECK_RESULT $?
    pcp2json -L -s 10 -t 2 $metric_name | grep '@timestamp'
    CHECK_RESULT $?
    pcp2json -K del,60 -s 10 -t 2 $metric_name | grep '@host'
    CHECK_RESULT $?
    pcp2json -c /etc/pcp/pmrep/collectl.conf -s 10 -t 2 $metric_name | grep '@instances'
    CHECK_RESULT $?
    pcp2json -C $metric_name | grep 'Waiting for'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
