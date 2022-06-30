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
#@Date      	:   2022-3-29 16:30:43
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
    expect <<-END
    log_file etcd_log
    spawn etcdctl user passwd root
    expect "Password of root:"
    send "12345\n"
    expect "Type password of root again for confirmation:"
    send "12345\n"
    sleep 5
    expect eof
END
    grep "Password updated" etcd_log
    CHECK_RESULT $? 0 0 "Check etcdctl user passwd root failed."
    etcdctl lease grant 100 | grep "TTL(100s)"
    CHECK_RESULT $? 0 0 "Check etcdctl lease grant failed."
    Lease=$(etcdctl lease grant 100 | awk '{print $2}')
    nohup etcdctl lease keep-alive $Lease >result 2>&1 &
    SLEEP_WAIT 10
    grep "keepalived" result
    CHECK_RESULT $? 0 0 "Check etcdctl lease keep-alive failed."
    etcdctl lease timetolive --keys $Lease | grep "$Lease"
    CHECK_RESULT $? 0 0 "Check etcdctl lease timetolive failed."
    etcdctl lease list | grep "$Lease"
    CHECK_RESULT $? 0 0 "Check etcdctl list failed."
    etcdctl lease revoke $Lease | grep "revoked"
    CHECK_RESULT $? 0 0 "Check etcdctl revoke failed."
    etcdctl lease list | grep "$Lease"
    CHECK_RESULT $? 1 0 "Check etcdctl list failed."
    etcdctl user del root | grep -i "User root deleted"
    CHECK_RESULT $? 0 0 "Check etcdctl user del failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop etcd
    rm -rf result etcd_log
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
