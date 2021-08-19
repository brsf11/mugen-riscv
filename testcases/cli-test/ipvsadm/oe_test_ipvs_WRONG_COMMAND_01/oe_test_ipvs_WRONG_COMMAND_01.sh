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
#@Date      	:   2020-07-10 09:00:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification ipvsadm‘s add/del/modify illegale command
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    check_port="Zero port specified for non-persistent service"
    check_parameter="Illegal 'Scheduler' option with the 'and-server' command"
    check_algorithm='Scheduler or persistence engine nt found'
    check_mode="-j:unknown option"
    VIP=$(echo ${NODE1_IPV4} | cut -d '.' -f 1-3).100
    DNF_INSTALL ipvsadm
    ip addr add $VIP/22 dev ${NODE2_NIC}
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    ipvsadm
    ipvsadm -C
    CHECK_RESULT "$(ipvsadm -A -t $VIP -s rr)" $check_port
    SLEEP_WAIT 2
    CHECK_RESULT "$(ipvsadm -a -t $VIP:80 -s rr)" $check_parameter
    SLEEP_WAIT 2
    CHECK_RESULT "$(ipvsadm -A -t $VIP:80 -s wr)" $check_algorithm
    SLEEP_WAIT 2
    CHECK_RESULT "$(ipvsadm -a -t $VIP:80 -r ${NODE2_IPV4}:80 -j)" $check_mode
    SLEEP_WAIT 2
    ipvsadm -A -t $VIP:80 -s rr
    ipvsadm -a -t $VIP:80 -r ${NODE3_IPV4} -g
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    ipvsadm -C
    ip addr del $VIP/22 dev ${NODE2_NIC}
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
