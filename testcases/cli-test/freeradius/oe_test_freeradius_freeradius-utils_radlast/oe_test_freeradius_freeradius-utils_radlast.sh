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
    cp /var/log/wtmp /var/log/radius/radwtmp
    test -e /var/log/radius/radwtmp

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    radtimes=3
    a=$(radlast -${radtimes} | grep -c "oot")
    [ "$radtimes" -eq "$a" ]
    CHECK_RESULT $? 0 0 "radlast -num execution failed."
    radlast -a | awk '{print $NF}' | grep -E "([0-9]{1,3}.){3}[0-9]"
    CHECK_RESULT $? 0 0 "radlast -a execution failed."
    radlast -3 -d
    CHECK_RESULT $? 0 0 "radlast -d execution failed."
    radlast --file /var/log/radius/radwtmp | grep "radwtmp begins"
    CHECK_RESULT $? 0 0 "radlast --file execution failed."
    radlast --fulltimes | grep -E "([0-9]{1,2}:){2}[0-9]{1,2}"
    CHECK_RESULT $? 0 0 "radlast --fulltimes execution failed."
    radlast -i | grep -E "([0-9]{1,3}.){3}[0-9]"
    CHECK_RESULT $? 0 0 "radlast -i execution failed."
    a=$(radlast -n ${radtimes} | grep -c "oot")
    [ "$radtimes" -eq "$a" ]
    CHECK_RESULT $? 0 0 "radlast -n execution failed."
    radlast -R | awk '{print $3}' | grep -e "Mon" -e "Tue" -e "Wed" -e "Sat" -e "Sun" -e "Thu" -e "Sat" -e "Fri"
    CHECK_RESULT $? 0 0 "radlast -R execution failed."
    a=$(radlast -s "00:00" | grep "logged in" | sed -n '$p' | awk '{print $(NF-3)}')
    b=$(radlast -s "00:00" | grep "logged in" | sed -n '$p' | awk '{print $(NF-3)}' | awk -F ':' '{print $1":"$2+1}')
    [ "$(radlast -s "$b" | grep "logged in" | sed -n '$p' | awk '{print $(NF-3)}')" != "$a" ]
    CHECK_RESULT $? 0 0 "radlast -s execution failed."

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
