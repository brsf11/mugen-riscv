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
# @Desc      :   Create an ext4 file system
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    echo -e "n\np\n1\n\n+20M\np\nw\n" | fdisk "/dev/${local_disk}"
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    mkfs.ext4 -F "/dev/${local_disk1}"
    CHECK_RESULT $?
    SLEEP_WAIT 3
    blkid | grep "/dev/${local_disk1}" | grep ext4
    CHECK_RESULT $?
    mkfs.ext4 -F -U a7784af8-d965-4ffe-8582-549cef1fa222 "/dev/${local_disk1}"
    CHECK_RESULT $?
    SLEEP_WAIT 3
    udevadm settle
    blkid | grep "/dev/${local_disk1}" | awk -F' ' '{print $2}' | grep a7784af8-d965-4ffe-8582-549cef1fa222
    CHECK_RESULT $?
    mkfs.ext4 -F -L newlable "/dev/${local_disk1}"
    CHECK_RESULT $?
    SLEEP_WAIT 3
    udevadm settle
    blkid | grep "/dev/${local_disk1}" | awk -F' ' '{print $2}' | grep newlable
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    echo -e "d\np\nw\n" | fdisk "/dev/${local_disk}"
    LOG_INFO "Finish environment cleanup."
}

main $@
