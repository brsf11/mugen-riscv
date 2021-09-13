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
#@Date      	:   2021-08-11
#@License   	:   Mulan PSL v2
#@Desc      	:   Check ipsec auto list cmd
#####################################

source ./common/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    SET_CONF
    ADD_CONN

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    ipsec auto --listpubkeys >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --listpubkeys failed."
    ipsec auto --listcerts >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --listcerts failed."
    ipsec auto --checkpubkeys >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --checkpubkeys failed."
    ipsec auto --listcacerts >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --listcacerts failed."
    ipsec auto --showonly --utc --listgroups >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --showonly --utc --listgroups failed."
    ipsec auto --listcrls >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --listcrls failed."
    ipsec auto --listall >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --listall failed."
    ipsec auto --purgeocsp >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --purgeocsp failed."
    ipsec auto --rereadsecrets >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --rereadsecrets failed."
    ipsec auto --rereadgroups >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --rereadgroups failed."
    # ipsec auto --rereadcrls has been obsoleted and replaced by ipsec crls
    ipsec crls
    CHECK_RESULT $? 0 0 "Check ipsec crls failed."
    ipsec auto --rereadcerts
    CHECK_RESULT $? 0 0 "Check ipsec auto --rereadcerts failed."
    ipsec auto --rereadall >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec auto --rereadall failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    REVERT_CONF

    LOG_INFO "End to restore the test environment."
}

main "$@"

