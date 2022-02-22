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
# @Date      :   2020/10/19
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in multipath-tools package
# ############################################

source "common_multipath-tools.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    test_mapper=$(ls /dev/mapper | grep mpath | head -n 1)
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mpathpersist --out --register --param-sark=12cdbe /dev/mapper/${test_mapper}
    CHECK_RESULT $?
    mpathpersist -v0 -i -k /dev/mapper/${test_mapper} | grep "0x12cdbe"
    CHECK_RESULT $?
    mpathpersist -i -k -H /dev/mapper/${test_mapper} | grep -2 "12cdbe"
    CHECK_RESULT $?
    mpathpersist --out --reserve --param-rk=12cdbe --prout-type=8 -d /dev/mapper/${test_mapper}
    CHECK_RESULT $?
    mpathpersist -i -r /dev/mapper/${test_mapper} | grep -1 "Key"
    CHECK_RESULT $?
    mpathpersist -i -c /dev/mapper/${test_mapper} | grep -A 20 "Report"
    CHECK_RESULT $?
    mpathpersist --out --release --param-rk=12cdbe --prout-type=8 -d /dev/mapper/${test_mapper}
    CHECK_RESULT $?
    mpathpersist --out --register-ignore -K 12cdbe -S 0 /dev/mapper/${test_mapper}
    CHECK_RESULT $?
    mpathpersist -v0 -i -k /dev/mapper/${test_mapper} | grep "0x12cdbe"
    CHECK_RESULT $? 0 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
