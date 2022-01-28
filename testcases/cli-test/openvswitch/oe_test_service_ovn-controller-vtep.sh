#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   wangdan
# @Contact   :   1743994506@qq.com
# @Date      :   2021/12/02
# @License   :   Mulan PSL v2
# @Desc      :   Test ovn-controller-vtep.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL openvswitch-ovn-vtep
    service=ovn-controller-vtep.service
    log_time=$(date '+%Y-%m-%d %T')
    flag=false
    if [ $(getenforce | grep Enforcing) ]; then
        setenforce 0
        flag=true
    fi
    userdel -rf openvswitch_ovn; useradd openvswitch_ovn
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    su - openvswitch_ovn <<EOF
    expect <<-END
        set timeout 30
        log_file /tmp/testlog1
        spawn service ${service} restart 
        expect "Password:"
        send "${NODE1_PASSWORD}\n"
        expect eof
END
EOF
    grep -iE "fail|error" /tmp/testlog1
    CHECK_RESULT $? 1 0 "${service} restart failed"
    su - openvswitch_ovn <<EOF
    expect <<-END
        set timeout 30
        log_file /tmp/testlog2
        spawn service ${service} stop
        expect "Password:"
        send "${NODE1_PASSWORD}\n"
        expect eof
END
EOF
    grep -iE "fail|error" /tmp/testlog2
    CHECK_RESULT $? 1 0 "${service} stop failed"
    SLEEP_WAIT 10
    su - openvswitch_ovn <<EOF
    expect <<-END
        set timeout 30
        log_file /tmp/testlog3
        spawn service ${service} start
        expect "Password:"
        send "${NODE1_PASSWORD}\n"
        expect eof
END
EOF
    grep -iE "fail|error" /tmp/testlog3
    CHECK_RESULT $? 1 0 "${service} start failed"
    su - openvswitch_ovn -c "service ${service} status" | grep "Active: active (running)"
    CHECK_RESULT $? 0 0 "${service} start failed"
    journalctl --since "${log_time}" -u "${service}" | grep -i "fail\|error" | grep -v -i "DEBUG\|INFO\|WARNING" | grep -v -i "[FAILED]"
    CHECK_RESULT $? 1 0 "There is an error message for the log of ${service}"
    su - openvswitch_ovn <<EOF
    expect <<-END
        set timeout 30
        log_file /tmp/testlog4
        spawn service ${service} reload
        expect "Password:"
        send "${NODE1_PASSWORD}\n"
        expect eof
END
EOF
    grep "Job type reload is not applicable for unit ${service}" /tmp/testlog4
    CHECK_RESULT $? 0 0 "${service} reload failed"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    su - openvswitch_ovn <<EOF
    expect <<-END
        spawn systemctl stop ${service}
        expect "Password:"
        send "${NODE1_PASSWORD}\n"
        expect eof
END
EOF
    userdel -rf openvswitch_ovn
    if [ ${flag} = 'true' ]; then
        setenforce 1
    fi
    rm -rf /tmp/testlog*
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
