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
# @Desc      :   Increase the size of the XFS file system
# #############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    DNF_INSTALL xfsdump
    echo "n

p


+40M
n

p


+40M
w" | fdisk "/dev/${local_disk}"
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    mkdir /home/pv
    pvcreate "/dev/${local_disk1}" -y
    vgcreate test "/dev/${local_disk1}" -y
    lvcreate -L 20MiB -n lv1 test -y
    CHECK_RESULT $?
    mkfs.xfs -f /dev/mapper/test-lv1
    CHECK_RESULT $?
    mount /dev/mapper/test-lv1 /home/pv
    CHECK_RESULT $?
    pvcreate "/dev/${local_disk2}" -y
    vgextend test "/dev/${local_disk2}" -y
    CHECK_RESULT $?
    lvextend -L +10MiB /dev/mapper/test-lv1 "/dev/${local_disk2}" -y
    CHECK_RESULT $?
    xfs_info /home/pv
    lvextend -L +10MiB /dev/mapper/test-lv1 "/dev/${local_disk2}" -y
    CHECK_RESULT $?
    xfs_growfs /home/pv -D 5500 | grep "blocks changed from 5120 to 5500"
    CHECK_RESULT $?
    xfs_growfs /home/pv | grep "data blocks changed from 5500 to"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /home/pv
    lvremove /dev/test/lv1 -y
    vgremove /dev/test -y
    pvremove "/dev/${local_disk2}" "/dev/${local_disk2}"
    rm -rf /home/pv
    echo "d

d

w" | fdisk "/dev/${local_disk}"
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
