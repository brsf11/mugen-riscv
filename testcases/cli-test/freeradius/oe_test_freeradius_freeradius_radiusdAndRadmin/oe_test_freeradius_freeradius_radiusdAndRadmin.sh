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
    echo -e "show version\nquit" >/tmp/radminfile
    radiusd_version=$(rpm -q freeradius | awk -F '-' '{print $2}')

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    radiusd -v | grep "${radiusd_version}"
    CHECK_RESULT $? 0 0 "radiusd -v execution failed."
    radiusd -X | grep Loading &
    CHECK_RESULT $? 0 0 "radiusd -X execution failed."
    kill -9 $(pgrep -f "radiusd -X")
    ln -s /etc/raddb/sites-available/control-socket /etc/raddb/sites-enabled/control-socket
    systemctl start radiusd
    SLEEP_WAIT 2
    radmin -d /etc/raddb </tmp/radminfile | grep "${radiusd_version}"
    CHECK_RESULT $? 0 0 "radmin -d execution failed."
    radmin -D /usr/share/freeradius </tmp/radminfile | grep "${radiusd_version}"
    CHECK_RESULT $? 0 0 "radmin -D execution failed."
    radmin -e "show version" | grep "${radiusd_version}"
    CHECK_RESULT $? 0 0 "radmin -e execution failed."
    [ $(radmin -E </tmp/radminfile | grep -c "show version") -eq 2 ]
    CHECK_RESULT $? 0 0 "radmin -E execution failed."
    radmin -f /var/run/radiusd/radiusd.sock </tmp/radminfile | grep "${radiusd_version}"
    CHECK_RESULT $? 0 0 "radmin -f execution failed."
    radmin -h | grep "Usage"
    CHECK_RESULT $? 0 0 "radmin -h execution failed."
    radmin -i /tmp/radminfile | grep "${radiusd_version}"
    CHECK_RESULT $? 0 0 "radmin -i execution failed."
    cp /etc/raddb/radiusd.conf /etc/raddb/test.conf
    radmin -n test </tmp/radminfile | grep "${radiusd_version}"
    CHECK_RESULT $? 0 0 "radmin -n execution failed."
    radmin -q >/tmp/test &
    [ ! -s /tmp/test ]
    CHECK_RESULT $? 0 0 "radmin -q execution failed."
    kill -9 $(pgrep -f "radmin -q")

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    systemctl stop radiusd
    DNF_REMOVE
    rm -rf /etc/raddb
    rm -rf /var/log/radius
    rm -rf /tmp/radminfile
    rm -rf /tmp/test

    LOG_INFO "End to restore the test environment."
}

main "$@"
