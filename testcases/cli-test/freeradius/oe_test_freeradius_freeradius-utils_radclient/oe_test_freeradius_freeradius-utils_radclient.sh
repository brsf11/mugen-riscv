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

    echo "Message-Authenticator = 0x00" | radclient -4 127.0.0.1 status testing123 | grep "Received Access-Accept"
    CHECK_RESULT $? 0 0 "radclient -4 execution failed."
    echo "Message-Authenticator = 0x00" | radclient -6 [::1] status testing123 | grep "Received Access-Accept"
    CHECK_RESULT $? 0 0 "radclient -6 execution failed."
    [ $(echo "Message-Authenticator = 0x00" | radclient -c 2 127.0.0.1 status testing123 | grep -c "Received Access-Accept") -eq 2 ]
    CHECK_RESULT $? 0 0 "radclient -c execution failed."
    echo "Message-Authenticator = 0x00" | radclient -d /etc/raddb 127.0.0.1 status testing123 | grep "Received Access-Accept"
    CHECK_RESULT $? 0 0 "radclient -d execution failed."
    echo "Message-Authenticator = 0x00" | radclient -D /usr/share/freeradius 127.0.0.1 status testing123 | grep "Received Access-Accept"
    CHECK_RESULT $? 0 0 "radclient -D execution failed."
    echo "Message-Authenticator = 0x00" >/tmp/test
    radclient -f /tmp/test 127.0.0.1 status testing123 | grep "Received Access-Accept"
    CHECK_RESULT $? 0 0 "radclient -f execution failed."
    echo "Message-Authenticator = 0x00" | radclient -F 127.0.0.1 status testing123 | grep "Received Access-Accept"
    CHECK_RESULT $? 0 0 "radclient -F execution failed."
    radclient -h 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "radclient -h execution failed."
    echo "Message-Authenticator = 0x00" | radclient -n 30 127.0.0.1 status testing123 | grep "Received Access-Accept"
    CHECK_RESULT $? 0 0 "radclient -n execution failed."

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
