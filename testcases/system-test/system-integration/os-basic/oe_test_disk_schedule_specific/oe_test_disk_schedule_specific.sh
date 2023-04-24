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
# @Desc      :   Temporarily sets the scheduler for a specific disk
# #############################################
source ../common/disk_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    check_free_disk
    old_scheduler=$(awk -F '[' '{print$2}' /sys/block/"${local_disk}"/queue/scheduler | awk -F ']' '{print$1}')
    echo bfq >/sys/block/"${local_disk}"/queue/scheduler
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start to run test."  
    awk -F '[' '{print$2}' /sys/block/"${local_disk}"/queue/scheduler | awk -F ']' '{print$1}' | grep bfq
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    echo "${old_scheduler}" >/sys/block/"${local_disk}"/queue/scheduler
    LOG_INFO "End to restore the test environment."
}

main $@
