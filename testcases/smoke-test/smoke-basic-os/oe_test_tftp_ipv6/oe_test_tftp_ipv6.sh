#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/07/06
# @License   :   Mulan PSL v2
# @Desc      :   Test tftp
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "xinetd tftp tftp-server net-tools"
    ifconfig ${NODE1_NIC} inet6 add 2001:250:250:250:250:250:250:222/64
    route -A inet6 add default gw 2001:250:250:250::1 dev ${NODE1_NIC}
    SLEEP_WAIT 3
    ping6 -c 3 2001:250:250:250:250:250:250:222
    sed -i 's/flags.*/flags = IPV6/' /etc/xinetd.d/tftp
    sed -i 's/disable.*/disable = no/' /etc/xinetd.d/tftp
    sed -i 's/server_args.*/server_args         = -s \/tmp\/tftpboot -c/' /etc/xinetd.d/tftp
    getenforce | grep Enforcing && setenforce 0
    systemctl status firewalld | grep failed && systemctl start firewalld
    mkdir /tmp/tftpboot
    systemctl restart xinetd
    systemctl restart tftp
    echo "hello1" >/tmp/tftpboot/hello1.txt
    chmod 644 /tmp/tftpboot/hello1.txt
    SLEEP_WAIT 3
    systemctl restart xinetd
    systemctl restart tftp
    SLEEP_WAIT 5
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    tftp -6 2001:250:250:250:250:250:250:222 -c get hello1.txt
    CHECK_RESULT $? 0 0 "Failed to execute tftp get"
    grep hello1 hello1.txt
    CHECK_RESULT $? 0 0 "Failed to find hello1"
    echo "hello2" >hello2.txt
    chmod 777 hello2.txt
    chmod 777 /tmp/tftpboot
    tftp -6 2001:250:250:250:250:250:250:222 -c put hello2.txt
    CHECK_RESULT $? 0 0 "Failed to execute put"
    grep hello2 /tmp/tftpboot/hello2.txt
    CHECK_RESULT $? 0 0 "Failed to find hello2"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/tftpboot hello*
    getenforce | grep Permissive && setenforce 1
    ifconfig ${NODE1_NIC} inet6 del 2001:250:250:250:250:250:250:222/64
    route -A inet6 del default gw 2001:250:250:250::1 dev ${NODE1_NIC}
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
