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
# @Desc      :   Create an ext3 file system
# ############################################

source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    check_free_disk
    mkfs.ext4 -F "/dev/${local_disk}"
    SLEEP_WAIT 3
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    echo -e "m\nn\np\n1\n\n+500M\np\nw\n" | fdisk /dev/${local_disk}
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    mkfs.ext3 -F /dev/${local_disk1}
    blkid | grep /dev/${local_disk1} | grep ext3
    CHECK_RESULT $?
    mkfs.ext3 -F -U a7784af8-d965-4ffe-8582-549cef1fa222 /dev/${local_disk1}
    CHECK_RESULT $?
    udevadm settle
    blkid | grep /dev/${local_disk1} | awk -F' ' '{print $2}' | grep a7784af8-d965-4ffe-8582-549cef1fa222
    CHECK_RESULT $?
    mkfs.ext3 -F -L newlable /dev/${local_disk1}
    CHECK_RESULT $?
    udevadm settle
    blkid | grep /dev/${local_disk1} | awk -F' ' '{print $2}' | grep newlable
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    echo -e "d\np\nw\n" | fdisk /dev/${local_disk}
    LOG_INFO "Finish environment cleanup."
}

main "$@"
