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
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   Set up the disk scheduler using udev rules
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    TEST_DISK=$(lsblk | grep disk | grep -v ":0" | awk '{print$1}'|sed -n 1p)
    old_scheduler=$(awk -F '[' '{print$2}' /sys/block/"${TEST_DISK}"/queue/scheduler | awk -F ']' '{print$1}')
    WWID=$(udevadm info --attribute-walk --name=/dev/"${TEST_DISK}" | grep wwid)
    cp /etc/udev/rules.d/99-scheduler.rules /etc/udev/rules.d/99-scheduler.rules.bak
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start to run test."
    echo "ACTION ==\"add|change\",SUBSYSTEM==\"block\",$WWID,ATTR{queue/scheduler}=\"mq-deadline\"" >/etc/udev/rules.d/99-scheduler.rules
    udevadm control --reload-rules
    CHECK_RESULT $?
    udevadm trigger --type=devices --action=change
    CHECK_RESULT $?
    awk -F '[' '{print$2}' /sys/block/"${TEST_DISK}"/queue/scheduler | awk -F ']' '{print$1}' | grep mq-deadline
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    echo "${old_scheduler}" >/sys/block/"$TEST_DISK"/queue/scheduler
    mv /etc/udev/rules.d/99-scheduler.rules.bak /etc/udev/rules.d/99-scheduler.rules -f
    udevadm control --reload-rules
    udevadm trigger --type=devices --action=change
    LOG_INFO "End to restore the test environment."
}

main $@
