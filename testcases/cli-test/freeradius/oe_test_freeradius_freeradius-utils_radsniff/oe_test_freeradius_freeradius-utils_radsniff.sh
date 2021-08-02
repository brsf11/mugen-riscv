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
#@Author        :   wangjingfeng
#@Contact       :   1136232498@qq.com
#@Date          :   2020/12/24
#@License       :   Mulan PSL v2
#@Desc          :   freeradius-utils command parameter automation use case
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    DNF_INSTALL "freeradius freeradius-utils"
    systemctl start radiusd
    SLEEP_WAIT 1

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    radsniff -e received -I ../common/test.pcap | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radsniff -e execution failed."
    radsniff -f udp -I ../common/test.pcap | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radsniff -f execution failed."
    radsniff -h | grep "Usage"
    CHECK_RESULT $? 0 0 "radsniff -h execution failed."
    radsniff -I ../common/test.pcap | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radsniff -I execution failed."
    radsniff -I ../common/test.pcap -l Message-Authenticator | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radsniff -l execution failed."
    radsniff -I ../common/test.pcap -L Message-AuthenticatoR | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radsniff -L execution failed."
    radsniff -m -I ../common/test.pcap | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radsniff -m execution failed."
    radsniff -p 1812 -I ../common/test.pcap | grep "1812"
    CHECK_RESULT $? 0 0 "radsniff -p execution failed."
    radsniff -P /tmp/radsniff.pid
    echo "Message-Authenticator = 0x00" | radclient 127.0.0.1 status testing123
    [ "$(cat /tmp/radsniff.pid)" -eq "$(pgrep -f "radsniff -P" | grep -v grep)" ]
    CHECK_RESULT $? 0 0 "radsniff -P execution failed."
    kill -9 $(cat /tmp/radsniff.pid)

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    systemctl stop radiusd
    DNF_REMOVE
    rm -rf /etc/raddb
    rm -rf /var/log/radius
    rm -rf /tmp/radsniff.pid

    LOG_INFO "End to restore the test environment."
}

main "$@"
