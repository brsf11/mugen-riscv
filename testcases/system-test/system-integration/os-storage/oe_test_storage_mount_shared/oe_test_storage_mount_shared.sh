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
# @Desc      :   Create a copy of the shared mount point
# #############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    fdisk /dev/"${loca_disk}" <<EOF
n
p
1

+200M
n
p
2

+200M
w
EOF
    mkfs.ext2 -F /dev/"${loca_disk}"1
    sleep 2
    mkfs.ext2 -F /dev/"${loca_disk}"2
    sleep 2
    udevadm settle
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    mount --bind /media /media
    CHECK_RESULT $?
    mount --make-shared /media
    CHECK_RESULT $?
    mount --bind /media /mnt
    CHECK_RESULT $?
    mkdir /media/cdrom
    mount /dev/"${loca_disk}"1 /media/cdrom
    echo "test" >/media/cdrom/test
    ls /media/cdrom | grep test
    CHECK_RESULT $?
    ls /mnt/cdrom | grep test
    CHECK_RESULT $?
    mkdir /mnt/flashdisk
    mount /dev/"${loca_disk}"2 /mnt/flashdisk
    echo "test" >/mnt/flashdisk/test
    find /media/flashdisk | grep test
    CHECK_RESULT $?
    find /mnt/flashdisk | grep test
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /mnt/flashdisk
    umount /media/cdrom
    umount /media
    rm -rf /media/cdrom /mnt/flashdisk
    echo "d
1
d
w" | fdisk /dev/"${loca_disk}"
    LOG_INFO "Finish environment cleanup."
}

main $@
