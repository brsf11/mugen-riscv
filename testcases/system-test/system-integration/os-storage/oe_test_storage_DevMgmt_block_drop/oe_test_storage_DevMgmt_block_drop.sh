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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   Enable online block dropping
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    echo -e "n\np\n1\n\n+20M\np\nw\n" | fdisk "/dev/${local_disk}"
    mkfs.xfs -f "/dev/${local_disk1}"
    SLEEP_WAIT 3
    udevadm settle
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    mkdir /home/data
    mount -o discard "/dev/${local_disk1}" /home/data
    CHECK_RESULT $?
    df -h | grep "/home/data"
    CHECK_RESULT $?
    umount /home/data
    cp /etc/fstab /etc/fstab.bak
    echo "/dev/${local_disk1} /home/data xfs discard 0 0" >>/etc/fstab
    mount -a
    df -h | grep "/home/data"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /home/data
    rm -rf /home/data
    mv /etc/fstab.bak /etc/fstab -f
    echo -e "d\np\nw\n" | fdisk "/dev/${local_disk}"
    LOG_INFO "Finish environment cleanup."
}

main "$@"
