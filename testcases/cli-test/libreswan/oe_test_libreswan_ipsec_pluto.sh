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
#@Author    	:   meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2021-08-10
#@License   	:   Mulan PSL v2
#@Desc      	:   Check ipsec pluto
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL libreswan
    ipsec restart
    touch testfile
    test -f /run/pluto/pluto.pid && rm -f /run/pluto/pluto.pid

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    # test dns
    ipsec pluto --dnssec-rootkey-file testfile && rm -f /run/pluto/pluto.pid
    CHECK_RESULT $? 0 0 "Check ipsec pluto --dnssec-rootkey-file failed."
    ipsec pluto --dnssec-trusted testfile && rm -f /run/pluto/pluto.pid
    CHECK_RESULT $? 0 0 "Check ipsec pluto --dnssec-trusted failed."
    ipsec pluto --leak-detective && rm -f /run/pluto/pluto.pid
    CHECK_RESULT $? 0 0 "Check ipsec pluto --leak-detective failed."
    ipsec pluto --version >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec pluto version failed."
    ipsec pluto --help >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec pluto help failed."

    # test debug 
    ipsec pluto --debug-none && rm -f /run/pluto/pluto.pid
    CHECK_RESULT $? 0 0 "Check ipsec pluto --debug-none failed."
    ipsec pluto --debug-all && rm -f /run/pluto/pluto.pid
    CHECK_RESULT $? 0 0 "Check ipsec pluto --debug-all failed."
    ipsec pluto --debug all && rm -f /run/pluto/pluto.pid
    CHECK_RESULT $? 0 0 "Check ipsec pluto --debug failed."

    # test listen
    ipsec pluto --listen ${NODE1_IPV4} && rm -f /run/pluto/pluto.pid
    CHECK_RESULT $? 0 0 "Check ipsec pluto --listen failed."
    ipsec pluto --listen-tcp && rm -f /run/pluto/pluto.pid
    CHECK_RESULT $? 0 0 "Check ipsec pluto --listen-tcp failed."
    ipsec pluto --no-listen-udp && rm -f /run/pluto/pluto.pid
    CHECK_RESULT $? 0 0 "Check ipsec pluto --no-listen-udp failed."

    # test log
    ipsec pluto --log-no-ip --stderrlog --logfile testlog && rm -f /run/pluto/pluto.pid
    CHECK_RESULT $? 0 0 "Check ipsec pluto --log-no-ip --stderrlog --logfile testlog failed."
    ipsec pluto --log-no-time --stderrlog && rm -f /run/pluto/pluto.pid
    CHECK_RESULT $? 0 0 "Check ipsec pluto --log-no-time --stderrlog failed."
    ipsec pluto --log-no-append --stderrlog && rm -f /run/pluto/pluto.pid
    CHECK_RESULT $? 0 0 "Check ipsec pluto --log-no-append --stderrlog failed."
    ipsec pluto --log-no-audit --stderrlog
    CHECK_RESULT $? 0 0 "Check ipsec pluto --log-no-audit --stderrlog failed."
    

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
 
    test -f /run/pluto/pluto.pid && rm -f /run/pluto/pluto.pid
    rm -f /run/pluto/pluto.pid testfile testlog
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"

