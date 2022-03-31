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
#@Date      	:   2022-3-29 14:30:43
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
    etcdctl --endpoints=http://127.0.0.1:2379 member list | grep "started"
    CHECK_RESULT $? 0 0 "Check etcdctl --endpoints member command failed."
    etcdctl --write-out=table --endpoints=127.0.0.1:2379 endpoint status | grep -i "ENDPOINT"
    CHECK_RESULT $? 0 0 "Check etcdctl --endpoints --write-out=table failed."
    etcdctl --write-out=table --endpoints=127.0.0.1:2379 endpoint health | grep "HEALTH"
    CHECK_RESULT $? 0 0 "Check etcdctl --endpoints --write-out=table health failed."
    etcdctl --endpoints=127.0.0.1:2379 endpoint health
    CHECK_RESULT $? 0 0 "Check etcdctl --endpoints health failed"
    etcdctl --endpoints=127.0.0.1:2379 endpoint status | grep "true"
    CHECK_RESULT $? 0 0 "Check etcdctl --endpoints status failed."
    etcdctl snapshot save snapshot.db | grep "Snapshot saved at snapshot.db"
    CHECK_RESULT $? 0 0 "Check etcdctl snapshot save command failed."
    etcdctl snapshot status snapshot.db
    CHECK_RESULT $? 0 0 "Check etcdctl snapshot status command failed."
    etcdctl snapshot status snapshot.db -w table | grep "HASH"
    CHECK_RESULT $? 0 0 "Check etcdctl snapshot status -w table command failed."
    etcdctl endpoint --cluster=true status -w table | grep "ENDPOINT"
    CHECK_RESULT $? 0 0 "Check etcdctl endpoint --cluster=true status command failed."
    etcdctl --endpoints 127.0.0.1:2379 move-leader 8e9e05c52164694d | grep "Leadership transferred"
    CHECK_RESULT $? 0 0 "Check etcdctl --endpoints endpoint move-leader command failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop etcd
    rm -rf snapshot.db
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
