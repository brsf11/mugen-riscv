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

    radzap -h 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "radzap -h execution failed."
    systemctl start radiusd
    SLEEP_WAIT 1
    radzap -d /etc/raddb/ -N 127.0.0.1 127.0.0.1 testing123 | grep "Accounting-Response"
    CHECK_RESULT $? 0 0 "radzap -d -N execution failed."
    radzap -D /usr/share/freeradius -N 127.0.0.1 127.0.0.1 testing123 | grep "Accounting-Response"
    CHECK_RESULT $? 0 0 "radzap -D -N execution failed."
    touch /var/log/radius/radutmp
    [ -e /var/log/radius/radutmp ]
    CHECK_RESULT $? 0 0 "touch radutmp failed."
    radzap -P 0 127.0.0.1 testing123 2>&1 | grep send
    CHECK_RESULT $? 0 0 "radzap -P execution failed."
    radzap -u steve 127.0.0.1 testing123 2>&1 | grep send
    CHECK_RESULT $? 0 0 "radzap -u execution failed."
    radzap -U steve 127.0.0.1 testing123 2>&1 | grep send
    CHECK_RESULT $? 0 0 "radzap -U execution failed."
    radzap -x -N 127.0.0.1 127.0.0.1 testing123 | grep "NAS-IP-Address"
    CHECK_RESULT $? 0 0 "radzap -x -N execution failed."
    systemctl stop radiusd

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
