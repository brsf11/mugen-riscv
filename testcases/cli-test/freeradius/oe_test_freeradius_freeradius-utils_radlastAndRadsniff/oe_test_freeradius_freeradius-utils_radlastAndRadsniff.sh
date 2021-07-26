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

    DNF_INSTALL "freeradius freeradius-utils net-tools"
    cp /var/log/wtmp /var/log/radius/radwtmp
    test -e /var/log/radius/radwtmp

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    [ $(radlast | grep -c "oot") -gt $(radlast -t "00:00" | grep -c "oot") ]
    CHECK_RESULT $? 0 0 "radlast -t execution failed."
    radlast -x | grep -e "runlevel" -e "shutdown"
    CHECK_RESULT $? 0 0 "radlast -x execution failed."
    radlast -h | grep "\-a"
    CHECK_RESULT $? 0 0 "radlast -h execution failed."
    radlast -V | grep $(last -V | awk '{print $NF}')
    CHECK_RESULT $? 0 0 "radlast -V execution failed."
    radsniff -a | grep $(ifconfig | sed -n '1p' | awk -F ':' '{print $1}')
    CHECK_RESULT $? 0 0 "radsniff -a execution failed."
    systemctl start radiusd
    SLEEP_WAIT 1
    radsniff -c 2 -I ../common/test.pcap | grep "Captured 2 packets"
    CHECK_RESULT $? 0 0 "radsniff -c execution failed."
    radsniff -C -I ../common/test.pcap 2>&1 | tee /tmp/test
    grep "UDP checksum" /tmp/test
    CHECK_RESULT $? 0 0 "radsniff -C execution failed."
    radsniff -d /etc/raddb -I ../common/test.pcap | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radsniff -d execution failed."
    radsniff -D /usr/share/freeradius -I ../common/test.pcap | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radsniff -D execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    systemctl stop radiusd
    DNF_REMOVE
    rm -rf /etc/raddb
    rm -rf /var/log/radius
    rm -rf /tmp/test

    LOG_INFO "End to restore the test environment."
}

main "$@"
