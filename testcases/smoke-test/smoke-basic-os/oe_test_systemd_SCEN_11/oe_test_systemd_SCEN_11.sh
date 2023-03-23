#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2022/06/17
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of systemd
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    echo "[Unit]
Description=Test Service A
Requires=TestB.service
[Service]
ExecStart=/usr/bin/sleep 200" >/usr/lib/systemd/system/TestA.service
    echo "[Unit]
Description=Test Service B
[Service]
ExecStart=/usr/bin/sleep 200" >/usr/lib/systemd/system/TestB.service
    systemctl daemon-reload
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl start TestB
    CHECK_RESULT $? 0 0 "TestB.service start failed"
    systemctl status TestB | grep running
    CHECK_RESULT $? 0 0 "TestB.service is not running"
    systemctl start TestA
    CHECK_RESULT $? 0 0 "TestA.service start failed"
    systemctl status TestA | grep running
    CHECK_RESULT $? 0 0 "TestA.service is not running"
    systemctl stop TestA
    CHECK_RESULT $? 0 0 "TestA.service stop failed"
    systemctl status TestB | grep running
    CHECK_RESULT $? 0 0 "TestB.service is still not running"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop TestB
    rm -rf /usr/lib/systemd/system/TestA.service /usr/lib/systemd/system/TestB.service
    LOG_INFO "End to restore the test environment."
}

main "$@"
