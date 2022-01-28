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
# @Desc      :   View partition-fdisk
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase!"
    fdisk -l | grep -iE "da|db|/dev/mapper" | grep -iE "EFI|LVM"
    CHECK_RESULT $?

    fdisk -lu | grep -iE "da|db|/dev/mapper" | grep -iE "EFI|LVM"
    CHECK_RESULT $?

    fdisk -v | grep "fdisk from"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

main "$@"
