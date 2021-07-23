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
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date      	:   2020-10-22 09:30:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification memcached‘s command
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL memcached
    systemctl start memcached
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    memcached -d -m 2048 -l 127.0.0.1 -p 11211 -u root -M
    CHECK_RESULT $?
    memcached -d -m 2048 -l 127.0.0.1 -p 11211 -v -u root
    CHECK_RESULT $?
    memcached -d -m 2048 -l 127.0.0.1 -p 11211 -vv -u root
    CHECK_RESULT $?
    memcached -d -m 2048 -l 127.0.0.1 -p 11211 -vvv -u root
    CHECK_RESULT $?
    memcached -d -p 11211 -f 1.5 -vv -u root
    CHECK_RESULT $?
    memcached -d -p 11211 -f 1.5 -u root -I 524288
    CHECK_RESULT $?
    memcached-tool 127.0.0.1:11211 stats | grep "hash_bytes.*524288"
    CHECK_RESULT $?
    memcached-tool 127.0.0.1:11211 display | grep "Item_Size"
    CHECK_RESULT $?
    memcached-tool 127.0.0.1:11211 | grep "Max_age"
    CHECK_RESULT $?
    memcached-tool 127.0.0.1:11211 stats | grep "Value"
    CHECK_RESULT $?
    memcached-tool 127.0.0.1:11211 dump
    CHECK_RESULT $?
    memcached-tool 127.0.0.1:11211 settings | grep "auth_enabled_sasl"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop memcached
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
