#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/11/03
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of keyring command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL python3-keyring
    pip3 install keyrings.alt
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mkdir demo
    CHECK_RESULT $?
    keyring --help | grep -E "Usage: keyring|-"
    CHECK_RESULT $?
    keyring --list-backend | grep "keyring"
    CHECK_RESULT $?
    KEYRING_BACKEND=$(keyring --list-backend | grep -E "keyrings.alt.*priority: 0.5" | awk '{print $1}')
    expect <<EOF
        spawn keyring set system username -b $KEYRING_BACKEND
        expect "Password for 'username' in 'system':" {send "test1\r"}
        expect eof
EOF
    keyring get system username -b $KEYRING_BACKEND
    CHECK_RESULT $?
    expect <<EOF
        spawn keyring del system username -b $KEYRING_BACKEND
        expect " " {send "test1\r"}
        expect eof
EOF
    keyring get system username -b $KEYRING_BACKEND
    CHECK_RESULT $? 1
    expect <<EOF
        spawn keyring set system username -b $KEYRING_BACKEND -p demo
        expect "Password for 'username' in 'system':" {send "apple1\r"}
        expect eof
EOF
    keyring get system username -b $KEYRING_BACKEND -p demo
    CHECK_RESULT $?
    expect <<EOF
        spawn keyring del system username -b $KEYRING_BACKEND -p demo
        expect " " {send "apple1\r"}
        expect eof
EOF
    keyring get system username -b $KEYRING_BACKEND -p demo
    CHECK_RESULT $? 1
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf demo
    pip3 uninstall keyrings.alt -y
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
