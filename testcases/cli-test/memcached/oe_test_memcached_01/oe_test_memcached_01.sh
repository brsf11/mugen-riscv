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
#@Date      	:   2020-07-02 09:00:43
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
    memcached -d start -u root
    CHECK_RESULT $?
    ps -ef | grep memcached
    CHECK_RESULT $?
    memcached -d shutdown -u root
    CHECK_RESULT $?
    memcached -d restart -u root
    CHECK_RESULT $?
    CHECK_RESULT $?
    memcached -d uninstall -u root
    CHECK_RESULT $?
    memcached -d install -u root
    CHECK_RESULT $?
    memcached -d -m 2048 -u root
    CHECK_RESULT $?
    memcached-tool 127.0.0.1:11211 settings | grep "Field"
    CHECK_RESULT $?
    memcached -d -l 127.0.0.1 -u root
    CHECK_RESULT $?
    memcached -d -m 1024 -l 127.0.0.1 -p 11211 -u root
    CHECK_RESULT $?
    memcached-tool 127.0.0.1:11211 settings |grep "maxconns.*1024"
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
