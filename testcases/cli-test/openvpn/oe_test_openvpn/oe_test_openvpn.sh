#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/15
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of openvpn command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL openvpn
    DNF_INSTALL openvpn 2
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    openvpn --help | grep "\--"
    CHECK_RESULT $?
    openvpn --version | grep "OpenVPN"
    CHECK_RESULT $?

    touch tt.vpn
    CHECK_RESULT $?
    nohup openvpn --local 127.0.0.1 --config tt.vpn --dev tun1 --ifconfig 10.4.0.1 10.4.0.2 --verb 9 >/dev/null 2>&1 &
    SLEEP_WAIT 5
    pgrep -f 'openvpn --local'
    CHECK_RESULT $?
    ping -c 3 10.4.0.1 >/dev/null
    CHECK_RESULT $?

    kill -9 $(pgrep -f 'openvpn --local')
    SLEEP_WAIT 15
    pgrep -f 'openvpn --local'
    CHECK_RESULT $? 1

    nohup openvpn --remote ${NODE2_IPV4} --dev tun1 --ifconfig 10.4.0.1 10.4.0.2 --verb 9 >/dev/null 2>&1 &
    CHECK_RESULT $?
    pgrep -f 'openvpn --remote'
    CHECK_RESULT $?

    P_SSH_CMD --node 2 --cmd "nohup openvpn --remote ${NODE1_IPV4} --dev tun1 --ifconfig 10.4.0.2 10.4.0.1 --verb 9 >/dev/null 2>&1 &"
    CHECK_RESULT $?
    remote_pid=$(P_SSH_CMD --node 2 --cmd "pgrep -f 'openvpn --remote'" | tail -n 1 | awk -F '\r' '{print $1}')
    CHECK_RESULT $?

    ping -c 3 10.4.0.2 >/dev/null
    CHECK_RESULT $?
    P_SSH_CMD --node 2 --cmd "ping -c 3 10.4.0.1 >/dev/null"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'openvpn --remote')
    SLEEP_WAIT 15
    pgrep -f 'openvpn --remote'
    CHECK_RESULT $? 1
    P_SSH_CMD --node 2 --cmd "kill -9 $remote_pid"
    SLEEP_WAIT 15
    P_SSH_CMD --node 2 --cmd "pgrep -f 'openvpn --remote'"
    CHECK_RESULT $? 1

    openvpn --genkey --secret key
    CHECK_RESULT $?
    grep -iE "[a-z0-9]|openvpn" key
    CHECK_RESULT $?

    SFTP put --localdir ./ --localfile key --remotedir ~ --node 2
    CHECK_RESULT $?
    P_SSH_CMD --node 2 --cmd "test -f key"
    CHECK_RESULT $?

    
    nohup openvpn --remote ${NODE2_IPV4} --dev tun1 --ifconfig 10.4.0.1 10.4.0.2 --verb 5 --secret key >/dev/null 2>&1 &
    SLEEP_WAIT 5
    pgrep -f 'openvpn --remote'
    CHECK_RESULT $?
    P_SSH_CMD --node 2 --cmd "nohup openvpn --remote ${NODE1_IPV4} --dev tun1 --ifconfig 10.4.0.2 10.4.0.1 --verb 5 --secret key >/dev/null 2>&1 &"
    CHECK_RESULT $?
    remote_pid=$(P_SSH_CMD --node 2 --cmd "pgrep -f 'openvpn --remote'" | tail -n 1 | awk -F '\r' '{print $1}')
    CHECK_RESULT $?

    ping -c 3 10.4.0.2 >/dev/null
    CHECK_RESULT $?
    P_SSH_CMD --node 2 --cmd "ping -c 3 10.4.0.1 >/dev/null"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'openvpn --remote')
    SLEEP_WAIT 15
    pgrep -f 'openvpn --remote'
    CHECK_RESULT $? 1
    P_SSH_CMD --node 2 --cmd "kill -9 $remote_pid"
    SLEEP_WAIT 15
    P_SSH_CMD --node 2 --cmd "pgrep -f 'openvpn --remote'"
    CHECK_RESULT $? 1

    expect <<EOF
        spawn openssl req -nodes -new -x509 -keyout client.key -out ca.crt
        expect "*]:" {send "\r"}
        expect "*]:" {send "\r"}
        expect "*]:" {send "\r"}
        expect "*]:" {send "\r"}
        expect "*]:" {send "\r"}
        expect "*]:" {send "\r"}
        expect "*]:" {send "\r"}
        expect eof
EOF

    expect <<EOF
        spawn openssl req -nodes -new -x509 -keyout client.key -out client.crt
        expect "*]:" {send "\r"}
        expect "*]:" {send "\r"}
        expect "*]:" {send "\r"}
        expect "*]:" {send "\r"}
        expect "*]:" {send "\r"}
        expect "*]:" {send "\r"}
        expect "*]:" {send "\r"}
        expect eof
EOF
    test -f client.key -a -f ca.crt -a -f client.crt
    CHECK_RESULT $?
    nohup openvpn --remote ${NODE2_IPV4} --dev tun1 --ifconfig 10.4.0.1 10.4.0.2 --tls-client --ca ca.crt --cert client.crt --key client.key --reneg-sec 60 --verb 5 >/dev/null 2>&1 &
    SLEEP_WAIT 5
    pgrep -f 'openvpn --remote'
    CHECK_RESULT $?
    ping -c 3 10.4.0.1 >/dev/null
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'openvpn --remote')
    SLEEP_WAIT 15
    pgrep -f 'openvpn --remote'
    CHECK_RESULT $? 1

    expect <<EOF
        spawn ssh -2 ${NODE2_USER}@${NODE2_IPV4}
        expect "yes/no" {send "yes\r"}
        expect "*password" { send "${NODE2_PASSWORD}\r"}
        expect "*]#" {send "openssl req -nodes -new -x509 -keyout server.key -out ca.crt\r"}
        expect "]:" {send "\r"}
        expect "]:" {send "\r"}
        expect "]:" {send "\r"}
        expect "]:" {send "\r"}
        expect "]:" {send "\r"}
        expect "]:" {send "\r"}
        expect "]:" {send "\r"}
        expect eof
EOF

    expect <<EOF
        spawn ssh -2 ${NODE2_USER}@${NODE2_IPV4}
        expect "yes/no" {send "yes\r"}
        expect "*password" { send "${NODE2_PASSWORD}\r"}
        expect "*]#" {send "openssl req -nodes -new -x509 -keyout server.key -out server.crt\r"}
        expect "]:" {send "\r"}
        expect "]:" {send "\r"}
        expect "]:" {send "\r"}
        expect "]:" {send "\r"}
        expect "]:" {send "\r"}
        expect "]:" {send "\r"}
        expect "]:" {send "\r"}
        expect eof
EOF

    P_SSH_CMD --node 2 --cmd "test -f ca.crt -a -f server.crt -a -f server.key"
    CHECK_RESULT $?
    P_SSH_CMD --node 2 --cmd "openssl dhparam -out dh1024.pem 1024"
    SLEEP_WAIT 15
    P_SSH_CMD --node 2 --cmd "test -f dh1024.pem"
    CHECK_RESULT $?
    P_SSH_CMD --node 2 --cmd "nohup openvpn --remote ${NODE1_IPV4} --dev tun1 --ifconfig 10.4.0.2 10.4.0.1 --tls-server --dh dh1024.pem --ca ca.crt --cert server.crt --key server.key --reneg-sec 60 --verb 5 >/dev/null 2>&1 &"
    CHECK_RESULT $?
    remote_pid=$(P_SSH_CMD --node 2 --cmd "pgrep -f 'openvpn --remote'" | tail -n 1 | awk -F '\r' '{print $1}')
    CHECK_RESULT $?
    P_SSH_CMD --node 2 --cmd "ping -c 3 10.4.0.2 >/dev/null"
    CHECK_RESULT $?
    P_SSH_CMD --node 2 --cmd "kill -9 $remote_pid"
    SLEEP_WAIT 15
    P_SSH_CMD --node 2 --cmd "pgrep -f 'openvpn --remote'"
    CHECK_RESULT $? 1
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -v ".sh")
    P_SSH_CMD --node 2 --cmd "rm -rf ca.crt dh1024.pem key server.crt server.key"
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
