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
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2021-1-5
#@License       :   Mulan PSL v2
#@Desc          :   mcelog is a tool used to check for hardware error on x86 Linux.
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    if [ "${NODE1_FRAME}" != "x86_64" ]; then
        echo "Non X86 architecture,this function is not supported"
        exit
    else
        DNF_INSTALL "mcelog gcc gcc-c++ flex dialog git"
    fi
    cat >correct <<EOF
CPU 1 BANK 2
STATUS corrected
RIP 0x12341234
EOF
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    aer-inject --help 2>&1 | grep 'Usage'
    CHECK_RESULT $?
    aer-inject --version 2>&1 | grep 'aer-inject'
    CHECK_RESULT $?

    echo "3" >/sys/devices/system/machinecheck/machinecheck0/tolerant
    CHECK_RESULT $?
    modprobe mce-inject
    CHECK_RESULT $?
    mce-inject correct
    CHECK_RESULT $?
    SLEEP_WAIT 3 "grep 'Hardware Error' /var/log/messages" 2
    CHECK_RESULT $?

    mcelog --help 2>&1 | grep 'Usage'
    CHECK_RESULT $?
    mcelog --ignorenodev --daemon --syslog --logfile=/var/log/mcelog --pidfile haha.txt
    CHECK_RESULT $?
    SLEEP_WAIT 3 "test -f /var/log/mcelog -a -f haha.txt" 2
    CHECK_RESULT $?
    test $(pgrep -f "mcelog --ignorenodev --daemon") -eq $(cat haha.txt)
    CHECK_RESULT $?
    mcelog --client
    CHECK_RESULT $?
    mcelog --ascii </var/log/mcelog | grep 'Hardware event'
    CHECK_RESULT $?
    mcelog --ascii --file /var/log/mcelog | grep 'Hardware event'
    CHECK_RESULT $?
    kill -9 $(pgrep -f "mcelog --ignorenodev --daemon")
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    echo "0" >/sys/devices/system/machinecheck/machinecheck0/tolerant
    rm -f correct /var/log/mcelog haha.txt
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
