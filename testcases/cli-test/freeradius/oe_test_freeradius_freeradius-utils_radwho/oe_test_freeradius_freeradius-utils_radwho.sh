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
    touch /var/log/radius/radutmp
    test -e /var/log/radius/radutmp

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    radwho -i | grep "Name"
    CHECK_RESULT $? 0 0 "radwho -i execution failed."
    [ -z "$(radwho -n | grep "Name")" ]
    CHECK_RESULT $? 0 0 "radwho -n execution failed."
    radwho -N 127.0.0.1 | grep "Name"
    CHECK_RESULT $? 0 0 "radwho -N execution failed."
    radwho -p | grep "Name"
    CHECK_RESULT $? 0 0 "radwho -p execution failed."
    radwho -P 0 | grep "Name"
    CHECK_RESULT $? 0 0 "radwho -P execution failed."
    [ -z "$(radwho -r | grep "Login")" ]
    CHECK_RESULT $? 0 0 "radwho -r execution failed."
    radwho -RZN 127.0.0.1 | grep "NAS-IP-Address"
    CHECK_RESULT $? 0 0 "radwho -RZ execution failed."
    radwho -s | grep "Name"
    CHECK_RESULT $? 0 0 "radwho -s execution failed."
    radwho -S | grep "Name"
    CHECK_RESULT $? 0 0 "radwho -S execution failed."
    radwho -u steve | grep "Name"
    CHECK_RESULT $? 0 0 "radwho -u execution failed."
    radwho -U steve | grep "Name"
    CHECK_RESULT $? 0 0 "radwho -U execution failed."

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
