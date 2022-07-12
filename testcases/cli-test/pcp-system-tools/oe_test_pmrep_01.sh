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
    pmrep --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pmrep -a $archive_data -A 10min $metric_name | grep 'count/s'
    CHECK_RESULT $?
    pmrep --archive-folio=/var/log/pcp/pmlogger/$(hostname)/Latest $metric_name | grep 'count/s'
    CHECK_RESULT $?
    pmrep --container=busybox -s 10 vfs.inodes.count | grep 'v.i.count'
    CHECK_RESULT $?
    pmrep -h $host_name -s 10 $metric_name | grep 'count/s'
    CHECK_RESULT $?
    pmrep -L -s 10 $metric_name | grep 'count/s'
    CHECK_RESULT $?
    pmrep -K del,60 -s 10 $metric_name | grep 'count/s'
    CHECK_RESULT $?
    pmrep -c /etc/pcp/pmrep/collectl.conf -s 10 $metric_name | grep 'count/s'
    CHECK_RESULT $?
    pmrep -C $metric_name | grep 'd.d.write'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
