#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   lutianxiong
# @Contact   :   lutianxiong@huawei.com
# @Date      :   2020-10-10
# @License   :   Mulan PSL v2
# @Desc      :   openssl test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    encry_file=/tmp/encry_$$
    decry_file=/tmp/decry_$$
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL openssl
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    openssl enc -des3 -pbkdf2 -pass pass:abc123 -in /etc/fstab -out $encry_file
    CHECK_RESULT $?
    diff /etc/fstab $encry_file && return 1
    openssl enc -d -des3 -pbkdf2 -pass pass:abc123 -in $encry_file -out $decry_file
    CHECK_RESULT $?
    diff /etc/fstab $decry_file
    CHECK_RESULT $?
    openssl req -newkey rsa:2048 -nodes -keyout rsa_private.key -x509 -out cert.crt -subj "/C=CN/O=openeuler/OU=oec"
    CHECK_RESULT $?
    openssl x509 -in cert.crt -noout -text | grep "CN" | grep "openeuler" | grep "oec"
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf cert.crt rsa_private.key $encry_file $decry_file
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@
