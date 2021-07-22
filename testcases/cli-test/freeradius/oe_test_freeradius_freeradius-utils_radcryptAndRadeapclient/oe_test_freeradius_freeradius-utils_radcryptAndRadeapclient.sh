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

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    radcrypt --des test123
    CHECK_RESULT $? 0 0 "radcrypt --des execution failed."
    radcrypt --md5 test123
    CHECK_RESULT $? 0 0 "radcrypt --md5 execution failed."
    radcrypt --check test123 $(radcrypt --md5 test123) | grep "Password OK"
    CHECK_RESULT $? 0 0 "radcrypt --check execution failed."
    systemctl start radiusd
    SLEEP_WAIT 1
    echo "Message-Authenticator = 0x00" | radeapclient -4 127.0.0.1 status testing123 | grep "Main loop: done"
    CHECK_RESULT $? 0 0 "radeapclient -4 execution failed."
    echo "Message-Authenticator = 0x00" | radeapclient -6 [::1] status testing123 | grep "Main loop: done"
    CHECK_RESULT $? 0 0 "radeapclient -6 execution failed."
    echo "Message-Authenticator = 0x00" | radeapclient -d /etc/raddb 127.0.0.1 status testing123 | grep "Main loop: done"
    CHECK_RESULT $? 0 0 "radeapclient -d execution failed."
    echo "Message-Authenticator = 0x00" | radeapclient -D /usr/share/freeradius 127.0.0.1 status testing123 | grep "Main loop: done"
    CHECK_RESULT $? 0 0 "radeapclient -D execution failed."
    echo "Message-Authenticator = 0x00" >/tmp/test
    radeapclient -f /tmp/test 127.0.0.1 status testing123 | grep "Main loop: done"
    CHECK_RESULT $? 0 0 "radeapclient -f execution failed."
    radeapclient -h | grep -i "Usage"
    CHECK_RESULT $? 0 0 "radeapclient -h execution failed."

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
