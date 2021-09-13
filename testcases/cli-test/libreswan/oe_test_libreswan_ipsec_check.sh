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
#@Date      	:   2021-08-09
#@License   	:   Mulan PSL v2
#@Desc      	:   Check ipsec status
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL libreswan
    ipsec restart
    ipsec initnss

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    ipsec verify | grep "OK" >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec verify failed."
    ipsec trafficstatus >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec trafficstatus failed."
    ipsec globalstatus >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec globalstatus failed."
    ipsec shuntstatus >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec shuntstatus failed."
    ipsec briefstatus >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec briefstatus failed."
    ipsec showstates >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec showstates failed."
    ipsec fips >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec fips failed."
    ipsec checknflog >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec checknflog failed."
    ipsec barf >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec barf failed."
    ipsec look >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec look failed."
    ipsec newhostkey >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec newhostkey failed."
    ipsec readwriteconf >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec readwriteconf failed."
    ipsec rsasigkey >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec rsasigkey failed."
    ipsec show >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec show failed."
    ipsec traffic >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec traffic failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -f /var/lib/ipsec/nss/*.db
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"

