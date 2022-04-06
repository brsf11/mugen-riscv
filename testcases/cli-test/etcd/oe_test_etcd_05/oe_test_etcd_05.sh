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
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date      	:   2022-3-29 17:30:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification etcd‘s command
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL etcd
    systemctl start etcd
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    systemctl status etcd | grep "active (running)"
    CHECK_RESULT $? 0 0 "Check etcd.service start failed"
    etcdctl defrag | grep "defragmenting"
    CHECK_RESULT $? 0 0 "Check etcdctl defrag failed."
    etcdctl --endpoints=:2379 endpoint status | grep "true"
    CHECK_RESULT $? 0 0 "Check etcdctl --endpoints failed."
    etcdctl alarm disarm
    CHECK_RESULT $? 0 0 "Check etcdctl alarm disarm failed."
    etcdctl alarm list
    CHECK_RESULT $? 0 0 "Check etcdctl alarm listfailed."
    etcdctl check datascale | grep "PASS:"
    CHECK_RESULT $? 0 0 "Check etcdctl check datascale failed."
    etcdctl check perf | grep "PASS:"
    CHECK_RESULT $? 0 0 "Check etcdctl check perf failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop etcd
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
