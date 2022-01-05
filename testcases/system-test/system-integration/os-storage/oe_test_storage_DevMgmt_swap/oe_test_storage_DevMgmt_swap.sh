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
# @Desc      :   swap management
# ############################################
source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    ADD_DISK="/dev/$(check_free_disk 1)"
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    fdisk "${ADD_DISK}" <<HGG
n
p
1

+1G
w
HGG
    mkfs.ext4 -F ${ADD_DISK}1
    SLEEP_WAIT 3
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    swapon /dev/mapper/openeuler-swap
    swapoff -v /dev/mapper/openeuler-swap
    CHECK_RESULT $?
    lvresize -f /dev/openeuler/swap -L -100M
    CHECK_RESULT $?
    lsblk | grep openeuler-swap | awk '{print$4}' | grep G
    CHECK_RESULT $?
    mkswap /dev/mapper/openeuler-swap
    CHECK_RESULT $?
    swapon -v /dev/mapper/openeuler-swap
    CHECK_RESULT $?
    CHECK_RESULT $(grep -c dm /proc/swaps) 1

    pvcreate -y "${ADD_DISK}1"
    SLEEP_WAIT 3
    vgcreate vg0 "${ADD_DISK}1"
    SLEEP_WAIT 3
    lvcreate -y -L 600M -n lv_test vg0
    SLEEP_WAIT 3
    lsblk | grep vg0-lv_test
    CHECK_RESULT $?
    mkswap /dev/vg0/lv_test
    CHECK_RESULT $?

    echo "/dev/vg0/lv_test swap swap defaults 0 0" >>/etc/fstab

    systemctl daemon-reload
    CHECK_RESULT $?
    swapon -v /dev/vg0/lv_test
    CHECK_RESULT $?
    CHECK_RESULT $(grep -c dm /proc/swaps) 2

    dd if=/dev/zero of=/swapfile bs=1024 count=65536
    mkswap /swapfile
    chmod 600 /swapfile
    echo "/swapfile swap swap defaults 0 0" >>/etc/fstab
    systemctl daemon-reload
    CHECK_RESULT $?
    swapon /swapfile
    CHECK_RESULT $?
    grep file /proc/swaps | grep "/swapfile"
    CHECK_RESULT $?

    swapoff -v /dev/vg0/lv_test
    lvreduce -f /dev/vg0/lv_test -L -500M
    CHECK_RESULT $?
    mkswap /dev/vg0/lv_test
    CHECK_RESULT $?
    swapon -v /dev/vg0/lv_test
    CHECK_RESULT $?
    size_lv=$(grep dm-2 /proc/swaps | awk '{print$3}')
    test "$size_lv" -lt 600000
    CHECK_RESULT $?

    swapoff -v /dev/vg0/lv_test
    SLEEP_WAIT 1
    lvremove -y /dev/vg0/lv_test
    CHECK_RESULT $?
    sed -i "/lv_test/d" /etc/fstab
    systemctl daemon-reload
    grep dm-2 /proc/swaps
    CHECK_RESULT $? 1

    swapoff -v /swapfile
    sed -i "/\/swapfile/d" /etc/fstab
    systemctl daemon-reload
    CHECK_RESULT $?
    grep swapfile /proc/swaps
    CHECK_RESULT $? 1
    rm -f /swapfile
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    vgremove -y /dev/vg0
    SLEEP_WAIT 2
    pvremove -y "${ADD_DISK}"1
    SLEEP_WAIT 1   
    fdisk "${ADD_DISK}" <<HEE
d
w
HEE
    lvextend -y -L+2G /dev/mapper/openeuler-swap
    LOG_INFO "Finish environment cleanup."
}

main $@
