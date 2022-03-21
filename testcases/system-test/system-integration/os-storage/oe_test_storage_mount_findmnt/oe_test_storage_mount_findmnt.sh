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
# @Desc      :   List currently mounted file systems
# #############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    echo "n

p


+200M
n

p


+200M
w" | fdisk /dev/"${local_disk}"
    mkfs.xfs -f /dev/"${local_disk1}"
    sleep 1
    mkfs.ext2 -F /dev/"${local_disk2}"
    sleep 1
    udevadm settle
    mkdir /tmp/data_xfs /tmp/data_ext
    mount /dev/"${local_disk1}" /tmp/data_xfs
    mount /dev/"${local_disk2}" /tmp/data_ext
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    findmnt | grep "/tmp/data_xfs"
    CHECK_RESULT $?
    findmnt | grep "/tmp/data_ext"
    CHECK_RESULT $?
    findmnt --types xfs | grep "/tmp/data_ext"
    CHECK_RESULT $? 1
    findmnt --types xfs | grep "/tmp/data_xfs"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /tmp/data_xfs
    umount /tmp/data_ext
    rm -rf /tmp/data_xfs /tmp/data_ext
    echo "d

d

w" | fdisk /dev/"${local_disk}"
    LOG_INFO "Finish environment cleanup."
}

main $@
