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
# @Desc      :   File system common command test-mkfs
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    echo -e "n\np\n1\n\n+20M\np\nw\n" | fdisk "/dev/${local_disk}"
    mkfs -t ext4 -F "/dev/${local_disk1}"
    SLEEP_WAIT 3
    mount "/dev/${local_disk1}" /mnt
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    umount /mnt
    CHECK_RESULT $?
    mkfs -t ext3 -F "/dev/${local_disk1}" | grep "done"
    CHECK_RESULT $?
    mkfs -V -t ext3 -F "/dev/${local_disk1}" | grep "done"
    CHECK_RESULT $?
    lsblk -fs "/dev/${local_disk1}" | grep ${local_disk1}
    CHECK_RESULT $?
    mkfs -h | grep "Usage"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    echo -e "d\np\nw\n" | fdisk "/dev/${local_disk}"
    LOG_INFO "Finish environment cleanup."
}

main $@
