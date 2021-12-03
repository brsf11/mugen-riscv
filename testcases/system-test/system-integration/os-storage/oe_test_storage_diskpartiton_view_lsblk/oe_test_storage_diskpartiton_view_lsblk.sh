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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   View partition-lsblk
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase!"
    lsblk | grep -iE "disk|part|lvm"
    CHECK_RESULT $?

    lsblk -l | grep -iE "TYPE|MOUNTPOINT"
    CHECK_RESULT $?

    lsblk -a | grep -iE "disk|part|lvm"
    CHECK_RESULT $?

    lsblk -h | grep Usage
    CHECK_RESULT $?

    lsblk -t | grep SCHED
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

main $@
