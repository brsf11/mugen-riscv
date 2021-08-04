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
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2020/12/21
# @License   :   Mulan PSL v2
# @Desc      :   Test ipsec command
# ##################################
source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL libreswan
    ipsec start
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ipsec auto --showonly --utc --purgeocsp | grep "ipsec whack --ctlsocket /run/pluto/pluto.ctl --utc --listall --purgeocsp"
    CHECK_RESULT $?
    ipsec whack --help 2>&1 | grep "whack"
    CHECK_RESULT $?
    rm -rf /etc/ipsec.d/*.db && ipsec initnss | grep "Initializing NSS database"
    CHECK_RESULT $?
    ipsec checknss
    CHECK_RESULT $?
    ipsec checknflog | grep "nflog ipsec capture disabled"
    CHECK_RESULT $?
    ipsec stopnflog
    CHECK_RESULT $?
    ipsec shuntstatus | grep "Bare Shunt list"
    CHECK_RESULT $?
    ipsec globalstatus | grep "total.ikev2.recv.notifies.status"
    CHECK_RESULT $?
    ipsec briefstatus | grep "000"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /var/lib/ipsec/nss/*.db
    ipsec stop
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
