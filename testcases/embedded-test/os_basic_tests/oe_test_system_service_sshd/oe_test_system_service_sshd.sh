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
# @Desc      :   Restart and stop the OpenSSH service repeatedly
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."

    for i in $(seq 1 10); do
        /etc/init.d/sshd stop
        CHECK_RESULT $? 0 0 "stop sshd fail"
        /etc/init.d/sshd start
        CHECK_RESULT $? 0 0 "start sshd fail"
        /etc/init.d/sshd restart
        CHECK_RESULT $? 0 0 "restart sshd fail"
        SLEEP_WAIT 2
    done

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    /etc/init.d/sshd restart

    LOG_INFO "End to restore the test environment."
}

main $@
