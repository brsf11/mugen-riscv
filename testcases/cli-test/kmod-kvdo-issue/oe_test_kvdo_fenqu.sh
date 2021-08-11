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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2021/02/04
# @License   :   Mulan PSL v2
# @Desc      :   Partition on the VOD volume, write data to the partition, restart and check whether the data is lost
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    SSH_CMD "dnf install -y vdo kmod-kvdo" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    TEST_NODE2_DISKS=$(TEST_DISK 2)
    TEST_NODE2_DISK=/dev/$(echo "${TEST_NODE2_DISKS}" | awk -F " " '{for(i=1;i<=NF;i++) if ($i!~/[0-9]/)j=i;print $j}')
    test -z "${TEST_NODE2_DISK}" && exit 1
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    SSH_CMD "vdo create --name=vdo1 --device=${TEST_NODE2_DISK} --vdoLogicalSize=1T --force" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?

    SSH_CMD "echo 'n\n\np\n\n\n+3G\nw' | fdisk /dev/mapper/vdo1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    SSH_CMD "partprobe /dev/mapper/vdo1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    sleep 1
    SSH_CMD "mkfs.xfs -K /dev/mapper/vdo1p1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    SSH_CMD "mount /dev/mapper/vdo1p1 /mnt/" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    SSH_CMD "echo mydata >/mnt/test" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    REMOTE_REBOOT 2 300
    SSH_CMD "partprobe /dev/mapper/vdo1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    sleep 1
    SSH_CMD "lsblk | grep vdo1p1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    SSH_CMD "mount /dev/mapper/vdo1p1 /mnt/" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    SSH_CMD "grep mydata /mnt/test" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?

    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    SSH_CMD "rm -rf /mnt/test
    umount /mnt
    echo 'd\n\nw' | fdisk /dev/mapper/vdo1
    partprobe /dev/mapper/vdo1
    vdo remove --name=vdo1
    dnf -y remove vdo kmod-kvdo" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
