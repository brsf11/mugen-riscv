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
# @Date      :   2020-4-10
# @License   :   Mulan PSL v2
# @Desc      :   Create an XFS file system
# #############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    echo "n

p


+20M
w" | fdisk "/dev/${local_disk}"
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    lsblk -fs "/dev/${local_disk1}"
    mkfs.xfs -f "/dev/${local_disk1}"
    CHECK_RESULT $?
    SLEEP_WAIT 2
    udevadm settle
    CHECK_RESULT $?
    FSTYPE=$(lsblk --fs "/dev/${local_disk1}" | awk '{if (NR>1){print $2}}')
    [ "$FSTYPE" == "xfs" ]
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    echo "d

w" | fdisk "/dev/${local_disk}"
    LOG_INFO "Finish environment cleanup."
}

main $@
