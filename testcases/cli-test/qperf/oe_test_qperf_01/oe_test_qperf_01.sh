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
#@Date      	:   2020-10-10 09:30:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification opencc‘s command
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL qperf
    DNF_INSTALL qperf 2
    SSH_CMD "systemctl stop firewalld && nohup qperf &" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    qperf ${NODE2_IPV4} tcp_bw | grep "tcp_bw:"
    CHECK_RESULT $?
    qperf ${NODE2_IPV4} tcp_lat | grep "tcp_lat:"
    CHECK_RESULT $?
    qperf ${NODE2_IPV4} udp_bw | grep "udp_bw:"
    CHECK_RESULT $?
    qperf ${NODE2_IPV4} udp_lat | grep "udp_lat:"
    CHECK_RESULT $?
    qperf -t 60 --use_bits_per_sec ${NODE2_IPV4} tcp_bw tcp_lat | grep -E "tcp_bw:|tcp_lat:"
    CHECK_RESULT $?
    qperf -t 60 --use_bits_per_sec ${NODE2_IPV4} udp_bw udp_lat | grep -E "udp_bw:|udp_lat:"
    CHECK_RESULT $?
    qperf -t 60 --use_bits_per_sec ${NODE2_IPV4} udp_bw tcp_bw | grep -E "udp_bw:|tcp_bw:"
    CHECK_RESULT $?
    qperf -t 60 --use_bits_per_sec ${NODE2_IPV4} udp_lat tcp_lat | grep -E "udp_lat:|tcp_lat:"
    CHECK_RESULT $?
    qperf ${NODE2_IPV4} -t 10 -vvu tcp_lat udp_lat conf | grep -E "tcp_lat:|udp_lat:|conf:"
    CHECK_RESULT $?
    qperf ${NODE2_IPV4} -oo msg_size:1:64K:*2 -vu tcp_bw tcp_lat | grep -E "tcp_bw:|tcp_lat:"
    CHECK_RESULT $?
    qperf ${NODE2_IPV4} -oo msg_size:1:64K:*2 -vu udp_bw udp_lat | grep -E "udp_bw:|udp_lat:"
    CHECK_RESULT $?
    qperf ${NODE2_IPV4} udp_lat quit | grep -E "udp_lat:|quit:"
    CHECK_RESULT $?
    qperf --help tests | grep -E "Miscellaneous|Socket Based"
    CHECK_RESULT $?
    qperf --help opts
    CHECK_RESULT $?
    qperf --help examples | grep "In these examples"
    CHECK_RESULT $?
    qperf --help options
    CHECK_RESULT $?
    qperf --version | grep "qperf"
    CHECK_RESULT $?
    qperf --help | grep "Synopsis"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    SSH_CMD "systemctl start firewalld" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "End to restore the test environment."
}
main "$@"
