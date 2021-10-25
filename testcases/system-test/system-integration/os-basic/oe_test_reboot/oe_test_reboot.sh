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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Reboot test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    EXECUTE_T="120m"
    DNF_INSTALL dmidecode
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    repet_num=0
    while [ ${repet_num} -le 50 ]; do
        echo "===========loop ${repet_num}=============="
        SSH_CMD "ls" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
        CHECK_RESULT $?

        SSH_CMD "reboot" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"

        ping -c 10 ${NODE2_IPV4} > lossfile
        grep -w "0% packet loss" lossfile
        CHECK_RESULT $? 1

        REMOTE_REBOOT_WAIT 2 10
        CHECK_RESULT $?
        ((repet_num++))
    done
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf lossfile
    LOG_INFO "End to restore the test environment."
}

main "$@"
