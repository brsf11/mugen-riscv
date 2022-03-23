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
# @Desc      :   Create a secondary mount point copy
# #############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    fdisk /dev/"${local_disk}" <<EOF
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
    mkfs.ext2 -F /dev/"${local_disk1}"
    sleep 2
    mkfs.ext2 -F /dev/"${local_disk2}"
    sleep 2
    CHECK_RESULT $?
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
    mount --make-slave /mnt
    CHECK_RESULT $?
    test -d /media/cdrom || mkdir -p /media/cdrom
    CHECK_RESULT $?
    mount /dev/"${local_disk1}" /media/cdrom
    CHECK_RESULT $?
    echo "test" >/media/cdrom/test
    CHECK_RESULT $?
    find /media/cdrom | grep test
    CHECK_RESULT $?
    find /mnt/cdrom | grep test
    CHECK_RESULT $?
    test -d /mnt/flashdisk || mkdir -p /mnt/flashdisk
    mount /dev/"${local_disk2}" /mnt/flashdisk
    CHECK_RESULT $?
    echo "test" >/mnt/flashdisk/test
    CHECK_RESULT $?
    CHECK_RESULT $(find /media/flashdisk | wc -l) 1
    find /mnt/flashdisk | grep test
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /mnt/flashdisk
    umount /media/cdrom
    umount /media
    umount /mnt
    rm -rf /media/cdrom /mnt/flashdisk
    echo "d
1
d
w" | fdisk /dev/"${local_disk}"
    LOG_INFO "Finish environment cleanup."
}

main $@
