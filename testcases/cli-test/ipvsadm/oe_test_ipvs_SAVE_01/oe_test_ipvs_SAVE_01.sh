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
#@Date      	:   2020-07-01 11:00:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification ipvsadm‘s save/restore command
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    SSH_SCP ../common/SAVE_RESROER.sh ${NODE2_USER}@${NODE2_IPV4}:/tmp/SAVE_RESROER.sh ${NODE2_PASSWORD}
    SSH_CMD "bash -x /tmp/SAVE_RESROER.sh start" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/etc/sysconfig/ipvsadm ./ipvsadm ${NODE2_PASSWORD}
    CHECK_RESULT "$(wc -l ./ipvsadm | grep -cE '2')" 1
    SLEEP_WAIT 5
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/tmp/ipvsadm_restore.txt ./ipvsadm_restore.txt ${NODE2_PASSWORD}
    CHECK_RESULT "$(grep -cE 'Route' ./ipvsadm_restore.txt)" 1
    CHECK_RESULT "$(grep -cE 'rr' ./ipvsadm_restore.txt)" 1
    SSH_CMD "ipvsadm -C && systemctl reboot &" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SLEEP_WAIT 60
    SSH_CMD "ipvsadm -R < /etc/sysconfig/ipvsadm && ipvsadm>>/tmp/ipvsadm_restore1.txt " ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/tmp/ipvsadm_restore1.txt ./ipvsadm_restore1.txt ${NODE2_PASSWORD}
    CHECK_RESULT "$(grep -cE 'Route' ./ipvsadm_restore1.txt)" 1
    CHECK_RESULT "$(grep -cE 'rr' ./ipvsadm_restore1.txt)" 1
    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    SSH_CMD "bash -x /tmp/SAVE_RESROER.sh stop" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rm -rf ./ipvsadm_*
    LOG_INFO "End to restore the test environment."
}
main "$@"
