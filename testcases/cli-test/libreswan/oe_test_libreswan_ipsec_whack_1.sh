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
#@Desc      	:   Check ipsec whack list
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL libreswan
    ipsec restart

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    ipsec whack --version >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --version failed."
    ipsec whack --listen >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --listen failed."
    ipsec whack --listpubkeys >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --listpubkeys failed."
    ipsec whack --listcerts >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --listcerts failed."
    ipsec whack --listcacerts >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --listcacerts failed."
    ipsec whack --listcrls >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --listcrls failed."
    ipsec whack --listpsks >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --listpsks failed."
    ipsec whack --listevents >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --listevents failed."
    ipsec whack --listall >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --listall failed."
    ipsec whack --ike-socket-errqueue-toggle >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --ike-socket-errqueue-toggle failed."
    ipsec whack --purgeocsp >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec whack --purgeocsp failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"

