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
ExecStart=/usr/bin/slee 200" >/usr/lib/systemd/system/TestA.service
    echo "[Unit]
Description=Test Service B
[Service]
ExecStart=/usr/bin/sleep 200" >/usr/lib/systemd/system/TestB.service
    systemctl daemon-reload
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl start TestA
    CHECK_RESULT $? 0 0 "TestA.service start success"
    systemctl status TestA | grep failed
    CHECK_RESULT $? 0 0 "TestA.service is not failed"
    systemctl stop TestB
    CHECK_RESULT $? 0 0 "TestB.service stop failed"
    systemctl status TestB | grep dead
    CHECK_RESULT $? 0 0 "TestB.service is not dead"
    systemctl restart TestB
    CHECK_RESULT $? 0 0 "TestB.service restart failed"
    systemctl status TestA | grep failed
    CHECK_RESULT $? 0 0 "TestA.service is still not failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    sed -i "s/slee/sleep/g" /usr/lib/systemd/system/TestA.service
    systemctl daemon-reload
    systemctl restart TestA
    systemctl stop TestA
    systemctl stop TestB
    rm -rf /usr/lib/systemd/system/TestA.service /usr/lib/systemd/system/TestB.service
    LOG_INFO "End to restore the test environment."
}

main "$@"
