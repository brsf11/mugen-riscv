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

    echo "Message-Authenticator = 0x00" | radclient -p 30 127.0.0.1 status testing123 | grep "Received Access-Accept"
    CHECK_RESULT $? 0 0 "radclient -p execution failed."
    a=$(echo "Message-Authenticator = 0x00" | radclient -q 127.0.0.1 status testing123)
    [ -z "${a}" ]
    CHECK_RESULT $? 0 0 "radclient -q execution failed."
    echo "Message-Authenticator = 0x00" | radclient -t 0.0000000000000000000000000000000000000000000000000000000001 127.0.0.1 status testing123 2>&1 | grep "No reply"
    CHECK_RESULT $? 0 0 "radclient -t execution failed."
    replay_times=5
    a=$(echo "Message-Authenticator = 0x00" | radclient -t 0.0000000000000000000000000000000000000000000000000000000001 -r ${replay_times} 127.0.0.1 status testing123 | grep -c "Sent")
    [ "${replay_times}" -eq "${a}" ]
    CHECK_RESULT $? 0 0 "radclient -r execution failed."
    echo "Message-Authenticator = 0x00" | radclient -s 127.0.0.1 status testing123 | grep "Packet summary"
    CHECK_RESULT $? 0 0 "radclient -s execution failed."
    echo "testing123" >/tmp/test
    echo "Message-Authenticator = 0x00" | radclient -S /tmp/test 127.0.0.1 status | grep "Received Access-Accept"
    CHECK_RESULT $? 0 0 "radclient -S execution failed."
    radclient -v | grep $(rpm -q freeradius-utils | awk -F '-' '{print $3}')
    CHECK_RESULT $? 0 0 "radclient -v execution failed."
    echo "Message-Authenticator = 0x00" | radclient -x 127.0.0.1 status testing123 | grep "Message-Authenticator"
    CHECK_RESULT $? 0 0 "radclient -x execution failed."
    echo "Message-Authenticator = 0x00" | radclient -P udp 127.0.0.1 status testing123 | grep "Received Access-Accept"
    CHECK_RESULT $? 0 0 "radclient -P execution failed."

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
