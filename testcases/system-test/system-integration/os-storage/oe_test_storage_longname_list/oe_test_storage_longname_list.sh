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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   List persistent named properties
# ############################################
source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    check_free_disk
    mkfs.ext4 -F /dev/${local_disk}
    LOG_INFO "Loading data is complete!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    lsblk --fs "/dev/${local_disk}" | awk '{if (NR>1){print$NF}}' | grep -E '[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}'
    CHECK_RESULT $?
    echo -e "n\np\n1\n\n\nw" | fdisk "/dev/${local_disk}"
    CHECK_RESULT $?
    mkfs.ext4 -F "/dev/${local_disk1}"
    CHECK_RESULT $?
    lsblk --output +PARTUUID "/dev/${local_disk1}"
    lsblk --fs "/dev/${local_disk1}" | awk '{if (NR>1){print$NF}}' | grep -E '[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}'
    CHECK_RESULT $?
    file /dev/disk/by-id/* | grep "/dev/disk/by-id/dm-name-openeuler"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    echo -e "d\nw" | fdisk "/dev/${local_disk}"
    LOG_INFO "Finish environment cleanup."
}
main $@
