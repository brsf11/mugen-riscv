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
#@Date      	:   2022-3-29 15:30:43
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
    expect <<-END
    log_file etcd_log1
    spawn etcdctl user add root
    expect "Password of root:"
    send "123456\n"
    expect "Type password of root again for confirmation:"
    send "123456\n"
    sleep 5
    expect eof
END
    grep "User root created" etcd_log1
    CHECK_RESULT $? 0 0 "Check etcdctl user add failed."
    expect <<-END
    log_file etcd_log2
    spawn etcdctl user add test
    expect "Password of test:"
    send "123\n"
    expect "Type password of test again for confirmation:"
    send "123\n"
    expect eof
END
    grep "User test created" etcd_log2
    CHECK_RESULT $? 0 0 "Check etcdctl user add failed."
    etcdctl --endpoints=http://127.0.0.1:2379 auth enable | grep -i "Authentication Enabled"
    CHECK_RESULT $? 0 0 "Check etcdctl auth enable failed."
    etcdctl role add role1 --user="root" --password="123456" | grep "Role role1 created"
    CHECK_RESULT $? 0 0 "Check etcdctl role add failed."
    etcdctl user grant-role test role1 --user="root" --password="123456" | grep "Role role1 is granted to user test"
    CHECK_RESULT $? 0 0 "Check etcdctl user grant-role failed."
    etcdctl role grant-permission role1 read a --user="root" --password="123456" | grep "Role role1 updated"
    CHECK_RESULT $? 0 0 "Check etcdctl role grant-permission failed."
    etcdctl --endpoints=http://127.0.0.1:2379 put a "123" --user="root" --password="123456" | grep "OK"
    CHECK_RESULT $? 0 0 "Check etcdctl put failed."
    etcdctl get a --user="test:123"
    CHECK_RESULT $? 0 0 "Check etcdctl get --user failed."
    etcdctl user list --user="root" --password="123456" | grep "root\|test"
    CHECK_RESULT $? 0 0 "Check etcdctl user list failed."
    etcdctl user delete test --user="root" --password="123456"
    CHECK_RESULT $? 0 0 "Check etcdctl user deletel failed."
    etcdctl user list --user="root" --password="123456" | grep "test"
    CHECK_RESULT $? 1 0 "Check etcdctl user deletel failed."
    etcdctl role delete role1 --user="root" --password="123456" | grep "Role role1 deleted"
    CHECK_RESULT $? 0 0 "Check etcdctl role deletel failed."
    etcdctl --endpoints=http://127.0.0.1:2379 --user="root" --password="123456" auth disable | grep "Authentication Disabled"
    CHECK_RESULT $? 0 0 "Check etcdctl auth disable failed."
    etcdctl user del root | grep -i "User root deleted"
    CHECK_RESULT $? 0 0 "Check etcdctl user del failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop etcd
    rm -rf etcd_log*
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
