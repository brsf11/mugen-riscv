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

    DNF_INSTALL "freeradius freeradius-utils vim vim-common"
    systemctl start radiusd
    SLEEP_WAIT 1

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    [ -z "$(radsniff -q -I ../common/test.pcap)" ]
    CHECK_RESULT $? 0 0 "radsniff -q execution failed."
    [ -z $(radsniff -I ../common/test.pcap -r 'Message-Authenticator = 0x00') ]
    CHECK_RESULT $? 0 0 "radsniff -r execution failed."
    [ -z $(radsniff -I ../common/test.pcap -R 'Message-Authenticator = 0x00') ]
    CHECK_RESULT $? 0 0 "radsniff -R execution failed."
    radsniff -s testing123 -I ../common/test.pcap | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radsniff -s execution failed."
    radsniff -S -I ../common/test.pcap | xxd -b | grep "$(xxd -b ../common/test.pcap)"
    CHECK_RESULT $? 0 0 "radsniff -S execution failed."
    radsniff -v | grep $(rpm -q freeradius-utils | awk -F '-' '{print $3}')
    CHECK_RESULT $? 0 0 "radsniff -v execution failed."
    radsniff -w /tmp/test.pcap -I ../common/test.pcap
    xxd -b /tmp/test.pcap | grep "$(xxd -b ../common/test.pcap)"
    CHECK_RESULT $? 0 0 "radsniff -w execution failed."
    radsniff -x -I ../common/test.pcap | grep "Authenticator-Field"
    CHECK_RESULT $? 0 0 "radsniff -x execution failed."
    radsniff -W 2 -I ../common/test.pcap | grep "Muting stats"
    CHECK_RESULT $? 0 0 "radsniff -W execution failed."
    radsniff -T 100 -I ../common/test.pcap | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radsniff -T execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    systemctl stop radiusd
    DNF_REMOVE
    rm -rf /etc/raddb
    rm -rf /var/log/radius
    rm -rf /tmp/test.pcap

    LOG_INFO "End to restore the test environment."
}

main "$@"
