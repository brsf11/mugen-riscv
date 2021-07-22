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
#@Date          :   2020/12/22
#@License       :   Mulan PSL v2
#@Desc          :   freeradius command parameter automation use case
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    DNF_INSTALL "freeradius"
    ln -s /etc/raddb/sites-available/control-socket /etc/raddb/sites-enabled/control-socket
    sed -i '/mode = rw/a mode = rw' /etc/raddb/sites-enabled/control-socket
    sed -i '1i "test" Cleartext-Password := "pass123"' /etc/raddb/users
    systemctl start radiusd
    SLEEP_WAIT 1

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    raddebug -c "&Framed-IP-Address == 127.0.0.1" &
    SLEEP_WAIT 1
    ps -ef | grep "tail -f /var/log/radius" | grep -v grep
    status=$?
    SLEEP_WAIT 60
    [ -z $(ps -ef | grep "raddebug -c" | grep -v grep) ] && [ "${status}" -eq 0 ]
    CHECK_RESULT $? 0 0 "raddebug -c execution failed."
    raddebug -d /etc/raddb/ &
    SLEEP_WAIT 1
    ps -ef | grep "tail -f /var/log/radius" | grep -v grep
    status=$?
    SLEEP_WAIT 60
    [ -z $(ps -ef | grep "raddebug -d" | grep -v grep) ] && [ "${status}" -eq 0 ]
    CHECK_RESULT $? 0 0 "raddebug -d execution failed."
    cp /etc/raddb/radiusd.conf /etc/raddb/test.conf
    raddebug -n test &
    SLEEP_WAIT 1
    ps -ef | grep "tail -f /var/log/radius" | grep -v grep
    status=$?
    SLEEP_WAIT 60
    [ -z $(ps -ef | grep "raddebug -n" | grep -v grep) ] && [ "${status}" -eq 0 ]
    CHECK_RESULT $? 0 0 "raddebug -n execution failed."
    raddebug -D /usr/share/freeradius &
    SLEEP_WAIT 1
    ps -ef | grep "tail -f /var/log/radius" | grep -v grep
    status=$?
    SLEEP_WAIT 60
    [ -z $(ps -ef | grep "raddebug -D" | grep -v grep) ] && [ "${status}" -eq 0 ]
    CHECK_RESULT $? 0 0 "raddebug -D execution failed."
    raddebug -i "$NODE1_IPV4" &
    SLEEP_WAIT 1
    ps -ef | grep "tail -f /var/log/radius" | grep -v grep
    status=$?
    SLEEP_WAIT 60
    [ -z $(ps -ef | grep "raddebug -i" | grep -v grep) ] && [ "${status}" -eq 0 ]
    CHECK_RESULT $? 0 0 "raddebug -i execution failed."
    raddebug -I "$NODE1_IPV6" &
    SLEEP_WAIT 1
    ps -ef | grep "tail -f /var/log/radius" | grep -v grep
    status=$?
    SLEEP_WAIT 60
    [ -z $(ps -ef | grep "raddebug -I" | grep -v grep) ] && [ "${status}" -eq 0 ]
    CHECK_RESULT $? 0 0 "raddebug -I execution failed."
    raddebug -f /var/run/radiusd/radiusd.sock &
    SLEEP_WAIT 1
    ps -ef | grep "tail -f /var/log/radius" | grep -v grep
    status=$?
    SLEEP_WAIT 60
    [ -z $(ps -ef | grep "raddebug -f" | grep -v grep) ] && [ "${status}" -eq 0 ]
    CHECK_RESULT $? 0 0 "raddebug -f execution failed."
    raddebug -t 2 &
    SLEEP_WAIT 1
    ps -ef | grep "tail -f /var/log/radius" | grep -v grep
    status=$?
    SLEEP_WAIT 2
    [ -z $(ps -ef | grep "raddebug -t" | grep -v grep) ] && [ "${status}" -eq 0 ]
    CHECK_RESULT $? 0 0 "raddebug -t execution failed."
    raddebug -u test &
    SLEEP_WAIT 1
    ps -ef | grep "tail -f /var/log/radius" | grep -v grep
    status=$?
    SLEEP_WAIT 60
    [ -z $(ps -ef | grep "raddebug -u" | grep -v grep) ] && [ "${status}" -eq 0 ]
    CHECK_RESULT $? 0 0 "raddebug -u execution failed."
    checkrad other 127.0.0.1 0 test 1
    stat=$?
    [ "$stat" -eq 0 ] || [ "$stat" -eq 1 ]
    CHECK_RESULT $? 0 0 "checkrad execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    systemctl stop radiusd
    DNF_REMOVE
    rm -rf /etc/raddb
    rm -rf /var/log/radius

    LOG_INFO "End to restore the test environment."
}

main "$@"
