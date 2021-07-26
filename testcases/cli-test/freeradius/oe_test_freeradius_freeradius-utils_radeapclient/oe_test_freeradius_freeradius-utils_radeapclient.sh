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
    systemctl start radiusd
    SLEEP_WAIT 1

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    echo "Message-Authenticator = 0x00" | radeapclient -p 30 127.0.0.1 status testing123 | grep "Main loop: done"
    CHECK_RESULT $? 0 0 "radeapclient -p execution failed."
    a=$(echo "Message-Authenticator = 0x00" | radeapclient -q 127.0.0.1 status testing123)
    [ -z "$a" ]
    CHECK_RESULT $? 0 0 "radeapclient -q execution failed."
    echo "Message-Authenticator = 0x00" | radeapclient -t 0.0000000000000000000000000000000000000000000000000000000001 -x 127.0.0.1 status testing123 | grep "Timeout"
    CHECK_RESULT $? 0 0 "radeapclient -t execution failed."
    replay_times=5
    a=$(echo "Message-Authenticator = 0x00" | radeapclient -t 0.0000000000000000000000000000000000000000000000000000000001 -r ${replay_times} -x 127.0.0.1 status testing123 | grep -c "Timeout")
    [ "${replay_times}" -eq "${a}" ]
    CHECK_RESULT $? 0 0 "radeapclient -r execution failed."
    echo "Message-Authenticator = 0x00" | radeapclient -s 127.0.0.1 status testing123 | grep "Total approved auths"
    CHECK_RESULT $? 0 0 "radeapclient -s execution failed."
    echo "testing123" >/tmp/secretfile
    echo "Message-Authenticator = 0x00" | radeapclient -S /tmp/secretfile 127.0.0.1 status | grep "Main loop: done"
    CHECK_RESULT $? 0 0 "radeapclient -S execution failed."
    radeapclient -v | grep -i "id"
    CHECK_RESULT $? 0 0 "radeapclient -v execution failed."
    echo "Message-Authenticator = 0x00" | radeapclient -x 127.0.0.1 status testing123 | grep "Message-Authenticator"
    CHECK_RESULT $? 0 0 "radeapclient -x execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    systemctl stop radiusd
    DNF_REMOVE
    rm -rf /etc/raddb
    rm -rf /var/log/radius
    rm -rf /tmp/secretfile

    LOG_INFO "End to restore the test environment."
}

main "$@"
