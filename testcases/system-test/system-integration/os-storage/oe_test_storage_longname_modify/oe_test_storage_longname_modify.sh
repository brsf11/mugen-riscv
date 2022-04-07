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
# @Desc      :   Modify persistent named properties
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    echo -e "n\np\n1\n\n+20M\nn\np\n2\n\n+20M\nn\np\n3\n\n+20M\np\nw\n" | fdisk /dev/${local_disk}
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    mkfs.ext2 -F "/dev/${local_disk1}" | grep "done"
    CHECK_RESULT $?
    lsblk --fs "/dev/${local_disk1}" | grep "${local_disk1}"
    CHECK_RESULT $?
    SLEEP_WAIT 3
    tune2fs -U 2222d19b-8674-41ab-9856-ac3d15d1195e -L new-label "/dev/${local_disk1}"
    CHECK_RESULT $?
    lsblk --fs "/dev/${local_disk1}" | awk '{if (NR>1){print $3}}' | grep "2222d19b-8674-41ab-9856-ac3d15d1195e"
    CHECK_RESULT $? 1 
    lsblk --fs "/dev/${local_disk1}" | awk '{if (NR>1){print $4}}' | sed -n '$p' | grep "new-label"
    CHECK_RESULT $? 1
    mkswap "/dev/${local_disk2}"
    CHECK_RESULT $?
    lsblk --fs "/dev/${local_disk2}" | grep ${local_disk2}
    CHECK_RESULT $?
    SLEEP_WAIT 3
    swaplabel --uuid 11114983-9331-4a61-8123-96ac6a817c41 --label new-label "/dev/${local_disk2}"
    CHECK_RESULT $?
    SLEEP_WAIT 1
    lsblk --fs "/dev/${local_disk2}" | awk '{if (NR>1){print $5}}' | grep "new-label"
    CHECK_RESULT $? 1
    lsblk --fs "/dev/${local_disk2}" | awk '{if (NR>1){print $4}}' | grep "11114983-9331-4a61-8123-96ac6a817c41"
    CHECK_RESULT $? 1
    mkfs.xfs -f "/dev/${local_disk3}"
    CHECK_RESULT $?
    lsblk --fs "/dev/${local_disk3}"
    CHECK_RESULT $?
    xfs_admin -U 8888016f-f432-45d9-933b-66f243174bed -L new-label "/dev/${local_disk3}"
    CHECK_RESULT $?
    SLEEP_WAIT 1
    lsblk --fs "/dev/${local_disk3}" | awk '{if (NR>1){print $3}}' | grep "new-label"
    CHECK_RESULT $? 
    lsblk --fs "/dev/${local_disk3}" | awk '{if (NR>1){print $4}}' | grep "8888016f-f432-45d9-933b-66f243174bed"
    CHECK_RESULT $? 
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    echo -e "d\n\nd\n\nd\n\np\nw\n" | fdisk "/dev/${local_disk}"
    LOG_INFO "Finish environment cleanup."
}

main $@
