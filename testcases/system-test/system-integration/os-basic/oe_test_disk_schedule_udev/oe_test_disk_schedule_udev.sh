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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   Set up the disk scheduler using udev rules
# #############################################
source ../common/disk_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    check_free_disk
    WWID=$(udevadm info --attribute-walk --name=/dev/"${local_disk}" | grep wwid)
    cp /etc/udev/rules.d/99-scheduler.rules /etc/udev/rules.d/99-scheduler.rules.bak
    echo "ACTION ==\"add|change\",SUBSYSTEM==\"block\",$WWID,ATTR{queue/scheduler}=\"mq-deadline\"" >/etc/udev/rules.d/99-scheduler.rules
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start to run test."    
    udevadm control --reload-rules
    CHECK_RESULT $?
    udevadm trigger --type=devices --action=change
    CHECK_RESULT $?
    awk -F '[' '{print$2}' /sys/block/"${local_disk}"/queue/scheduler | awk -F ']' '{print$1}' | grep mq-deadline
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /etc/udev/rules.d/99-scheduler.rules
    mv /etc/udev/rules.d/99-scheduler.rules.bak /etc/udev/rules.d/99-scheduler.rules
    udevadm control --reload-rules
    udevadm trigger --type=devices --action=change
    LOG_INFO "End to restore the test environment."
}

main $@
