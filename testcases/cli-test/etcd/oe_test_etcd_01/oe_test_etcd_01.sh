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
#@Date      	:   2022-3-29 09:30:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification etcd‘s command
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL etcd
    systemctl start etcd
    version=$(rpm -qa etcd | awk -F "-" '{print$2}')
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    systemctl status etcd | grep "active (running)"
    CHECK_RESULT $? 0 0 "Check etcd.service start failed"
    etcd --help 2>&1 | grep -i "Usage:"
    CHECK_RESULT $? 0 0 "Check etcd --help failed."
    test "$(etcd --version | awk '{print $3}' | head -1)" == $version
    CHECK_RESULT $? 0 0 "Check etcd --version failed."
    test "$(etcdctl version | awk '{print $3}' | head -1)" == $version
    CHECK_RESULT $? 0 0 "Check etcdctl version failed."
    etcdctl help | grep -i "USAGE:"
    CHECK_RESULT $? 0 0 "Check etcdctl help failed."
    etcdctl --endpoints=http://127.0.0.1:2379 put a "123" | grep -i "OK"
    CHECK_RESULT $? 0 0 "Check etcdctl --endpoints put command failed."
    etcdctl --endpoints=http://127.0.0.1:2379 get a | grep "123"
    CHECK_RESULT $? 0 0 "Check etcdctl --endpoints get command failed."
    etcdctl --endpoints=http://127.0.0.1:2379 get a -w=json | grep "version"
    CHECK_RESULT $? 0 0 "Check etcdctl --endpoints get -w=json command failed."
    etcdctl --endpoints=http://127.0.0.1:2379 del a | grep "1"
    CHECK_RESULT $? 0 0 "Check etcdctl --endpoints del command failed."
    etcdctl --endpoints=http://127.0.0.1:2379 del a | grep "0"
    CHECK_RESULT $? 0 0 "Check etcdctl --endpoints del command failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop etcd
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
