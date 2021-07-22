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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/12/15
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in ndisc6-server binary package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "nbdkit nbdkit-server nbdkit-plugins gnutls-utils"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    certtool --generate-privkey >ca-key.pem
    chmod 0600 ca-key.pem
    certtool --generate-privkey >server-key.pem
    chmod 0600 server-key.pem
    certtool --generate-privkey >client-key.pem
    chmod 0600 client-key.pem
    nbdkit --tls-certificates=/root/ndbkit/ example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    mkdir -m 0700 /tmp/keys
    psktool -u rich -p /tmp/keys/keys.psk
    nbdkit --tls=require --tls-psk=/tmp/keys/keys.psk example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit --tls=on --tls-psk=/tmp/keys/keys.psk example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit --tls off example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit --tls-verify-peer example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit -U - example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit -u root example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit -v example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit_version=$(rpm -qa nbdkit | awk -F '-' '{print $2}')
    nbdkit -V | grep "$nbdkit_version"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ca-key.pem client-key.pem server-key.pem /tmp/keys
    LOG_INFO "End to restore the test environment."
}

main "$@"
