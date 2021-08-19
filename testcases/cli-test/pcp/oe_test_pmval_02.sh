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
#@Desc          :   pcp testing(pmval)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    metric_name=disk.dev.write
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pmval -L -s 10 $metric_name | grep 'samples'
    CHECK_RESULT $?
    pmval --container=busybox vfs.inodes.count -s 10 | grep 'interval'
    CHECK_RESULT $?
    pmval --derived=/var/lib/pcp/config/pmieconf/dm -s 10 $metric_name | grep 'count / sec'
    CHECK_RESULT $?
    pmval -a $archive_data -d -s 10 $metric_name | grep 'start'
    CHECK_RESULT $?
    pmval -f 3 -s 10 $metric_name | grep 'host'
    CHECK_RESULT $?
    pmval -i "'1 minute','5 minute'" -s 10 kernel.all.load | grep 'kernel.all.load'
    CHECK_RESULT $?
    pmval -r -s 10 $metric_name | grep 'cumulative counter'
    CHECK_RESULT $?
    pmval -v -s 10 $metric_name | grep 'count / sec'
    CHECK_RESULT $?
    pmval -w 5 -s 10 $metric_name | grep 'metric'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
