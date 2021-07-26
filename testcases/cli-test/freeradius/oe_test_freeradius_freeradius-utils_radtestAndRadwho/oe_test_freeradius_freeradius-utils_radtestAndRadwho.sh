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
    echo "steve  Cleartext-Password := \"testing\"
       Service-Type = Framed-User,
       Framed-Protocol = PPP,
       Framed-IP-Address = 172.16.3.33,
       Framed-IP-Netmask = 255.255.255.0,
       Framed-Routing = Broadcast-Listen,
       Framed-Filter-Id = \"std.ppp\",
       Framed-MTU = 1500,
       Framed-Compression = Van-Jacobsen-TCP-IP
    " >>/etc/raddb/users
    systemctl start radiusd
    SLEEP_WAIT 2

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    radtest -d /etc/raddb/ steve testing localhost 0 testing123 | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radtest -d execution failed."
    radtest -t pap steve testing localhost 0 testing123 | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radtest -t execution failed."
    radtest -P udp steve testing localhost 0 testing123 | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radtest -P execution failed."
    radtest -x steve testing localhost 0 testing123 | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radtest -x execution failed."
    radtest -4 steve testing localhost 0 testing123 | grep "Access-Accept"
    CHECK_RESULT $? 0 0 "radtest -4 execution failed."
    radtest -6 steve testing localhost 0 testing123 | grep "\["
    CHECK_RESULT $? 0 0 "radtest -6 execution failed."
    systemctl stop radiusd
    touch /var/log/radius/radutmp
    radwho -c | grep "Name"
    CHECK_RESULT $? 0 0 "radwho -c execution failed."
    radwho -d /etc/raddb/ | grep "Name"
    CHECK_RESULT $? 0 0 "radwho -d execution failed."
    radwho -F /var/log/radius/radutmp | grep "Name"
    CHECK_RESULT $? 0 0 "radwho -F execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE
    rm -rf /etc/raddb
    rm -rf /var/log/radius

    LOG_INFO "End to restore the test environment."
}

main "$@"
