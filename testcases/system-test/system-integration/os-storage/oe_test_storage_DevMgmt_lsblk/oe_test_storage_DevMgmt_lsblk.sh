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
# @Date      :   2020-04-27
# @License   :   Mulan PSL v2
# @Desc      :   Query disk attributes: lsblk
# ############################################
source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    disk_list=($(check_free_disk 2))
    local_disk_a=${disk_list[0]}
    local_disk=${disk_list[1]}
    DISK_A="/dev/${local_disk_a}"
    ADD_DISK="/dev/${local_disk}"
    new_uuid=12d59867-ff81-40d8-a7e7-45e971d31255
    LOG_INFO "Loading data is complete!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    mkfs.ext4 -F ${DISK_A}
    CHECK_RESULT $(lsblk --fs "${DISK_A}" | grep -i "${local_disk_a}" | awk '{print$4}' | wc -l) 1
    count_uuid=$(lsblk --output +UUID "${DISK_A}" | grep "${local_disk_a}" | awk '{print$7}' | wc -l)
    test ${count_uuid} -gt 0
    CHECK_RESULT $?
    mkfs.ext4 -F "${ADD_DISK}"
    CHECK_RESULT $?
    disk_uuid=$(lsblk --fs ${ADD_DISK} | grep "${local_disk}" | awk '{print$4}')
    tune2fs -U ${new_uuid} -L new-label "${ADD_DISK}"
    SLEEP_WAIT 2
    modify_uuid=$(lsblk --fs ${ADD_DISK} | grep "${local_disk}" | awk '{print$5}')
    [ ${modify_uuid}X == ${new_uuid}X ]
    CHECK_RESULT $?

    mkfs.xfs -f "${ADD_DISK}"
    CHECK_RESULT $?
    disk_uuid=$(lsblk --fs ${ADD_DISK} | grep "${local_disk}" | awk '{print$3}')
    xfs_admin -U ${new_uuid} -L new-label "${ADD_DISK}"
    SLEEP_WAIT 2
    modify_uuid=$(lsblk --fs ${ADD_DISK} | grep "${local_disk}" | awk '{print$4}')
    [ ${modify_uuid}X == ${new_uuid}X ]
    CHECK_RESULT $?
    mkfs.xfs -f "${ADD_DISK}"
    CHECK_RESULT $?

    disk_uuid=$(lsblk --fs /dev/mapper/openeuler-swap | grep "openeuler-swap" | awk '{print$4}')
    swapoff /dev/mapper/openeuler-swap
    swaplabel -U ${new_uuid} -L new-label /dev/mapper/openeuler-swap
    SLEEP_WAIT 2
    modify_uuid=$(lsblk --fs /dev/mapper/openeuler-swap | grep "openeuler-swap" | awk '{print$5}')
    [ ${modify_uuid}X == ${new_uuid}X ]
    CHECK_RESULT $?
    swaplabel -U ${disk_uuid} -L '' /dev/mapper/openeuler-swap
    CHECK_RESULT $?
    swapon -a
    LOG_INFO "End of testcase execution."
}

main $@
