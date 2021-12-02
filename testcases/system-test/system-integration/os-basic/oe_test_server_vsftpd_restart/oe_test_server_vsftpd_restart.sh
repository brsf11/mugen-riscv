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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-10
# @License   :   Mulan PSL v2
# @Desc      :   Start and stop the FTP service repeatedly
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "net-tools vsftpd"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    for i in $(seq 1 50); do
        systemctl start vsftpd
        systemctl status vsftpd | grep running
        CHECK_RESULT $?
        netstat -tulnp | grep 21
        CHECK_RESULT $?
        systemctl restart vsftpd
        systemctl status vsftpd | grep running
        CHECK_RESULT $?
        systemctl stop vsftpd
        systemctl status vsftpd | grep dead
        CHECK_RESULT $?
        SLEEP_WAIT 2
    done
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main $@
