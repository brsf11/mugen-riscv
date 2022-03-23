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
# @Desc      :   Unmount the file system with umount
# #############################################

source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    echo "n

p


+20M
w" | fdisk /dev/"${local_disk}"
    mkfs.xfs -f /dev/"${local_disk1}"
    sleep 2
    udevadm settle
    mkdir /tmp/data
    cp /etc/fstab /etc/fstab.bak
    echo "/dev/${local_disk1} /tmp/data xfs defaults 0 0" >>/etc/fstab
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    mount /tmp/data
    CHECK_RESULT $?
    df -h | grep "/tmp/data"
    CHECK_RESULT $?
    umount /tmp/data
    df -h | grep "/tmp/data"
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /tmp/data /tmp/boot
    mv /etc/fstab.bak /etc/fstab -f
    echo "d

w" | fdisk /dev/"${local_disk}"
    LOG_INFO "Finish environment cleanup."
}

main $@
