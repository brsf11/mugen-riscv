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
#@Desc          :   pcp testing(pmstore,install-sh)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    metric_name=disk.dev.write
    echo "Happy everyday" >file
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pmstore --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pmstore -h $host_name $metric_name 1 | grep 'No permission'
    CHECK_RESULT $?
    pmstore -L $metric_name 1 | grep 'No permission'
    CHECK_RESULT $?
    pmstore -K del,60 $metric_name 1 | grep 'No permission'
    CHECK_RESULT $?
    pmstore -n /var/lib/pcp/pmns/root $metric_name 1 | grep 'No permission'
    CHECK_RESULT $?
    pmstore -F $metric_name 1 | grep 'No permission'
    CHECK_RESULT $?
    pmstore -f $metric_name 1 | grep 'No permission'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/install-sh -o root -g root -d /tmp/pcp
    CHECK_RESULT $?
    test -d /tmp/pcp
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/install-sh -o root -g root file /tmp/pcp/file
    CHECK_RESULT $?
    test -f /tmp/pcp/file
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/pcp file
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
