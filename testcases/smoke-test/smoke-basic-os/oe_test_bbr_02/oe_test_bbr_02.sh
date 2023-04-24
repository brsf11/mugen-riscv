#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   dingjiao
#@Contact   	:   15829797643@163.com
#@Date      	:   2022-07-06
#@License   	:   Mulan PSL v2
#@Desc      	:   Turn on BBR algorithm
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    echo bbr >/proc/sys/net/ipv4/tcp_congestion_control
    CHECK_RESULT $? 0 0 "Turn on BBR algorithm: failed!"
    grep 'bbr' /proc/sys/net/ipv4/tcp_congestion_control
    CHECK_RESULT $? 0 0 "Check BBR is added to the tcp_congestion_control: failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    sed -i '/bbr/d' /proc/sys/net/ipv4/tcp_congestion_control
    LOG_INFO "End to restore the test environment."
}

main "$@"
