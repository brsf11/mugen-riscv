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
# @Desc      :   Mount repeatedly mounts and writes files after unmounting
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
    for count_mount in $(seq 1 10); do
        mount /tmp/data
        df -h | grep '/tmp/data'
        CHECK_RESULT $?
        umount /tmp/data
        CHECK_RESULT $?
    done
    mount /tmp/data
    CHECK_RESULT $?
    df -h | grep '/tmp/data'
    CHECK_RESULT $?
    echo "hello" >/tmp/data/test
    CHECK_RESULT $?
    grep "hello" /tmp/data/test
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /tmp/data
    rm -rf /tmp/data
    mv /etc/fstab.bak /etc/fstab -f
    echo "d

w" | fdisk /dev/"${local_disk}"
    LOG_INFO "Finish environment cleanup."
}

main $@
