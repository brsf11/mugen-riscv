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
    ipsec showstates
    CHECK_RESULT $?
    ipsec fips | grep "FIPS mode disabled"
    CHECK_RESULT $?
    ipsec cavp -h | grep "cavp"
    CHECK_RESULT $?
    ipsec letsencrypt --help | grep "letsencrypt"
    CHECK_RESULT $?
    ipsec look | grep "XFRM"
    CHECK_RESULT $?
    ipsec initnss --nssdir /var/lib/ipsec/nss
    ipsec newhostkey 2>&1 | grep key
    CHECK_RESULT $?
    ipsec showhostkey --list | grep "RSA keyid"
    CHECK_RESULT $?
    rm -rf /run/pluto/pluto.pid && ipsec pluto
    [ -e /run/pluto/pluto.pid ] && [ -e /run/pluto/pluto.ctl ]
    CHECK_RESULT $?
    ipsec readwriteconf | grep conf
    CHECK_RESULT $?
    ipsec setup --status | grep "ipsec.service"
    CHECK_RESULT $?
    ipsec verify | grep "Verifying installed system and configuration files"
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
