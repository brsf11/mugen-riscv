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
# @Desc      :   Ext3 compatibility
# ############################################
source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    check_free_disk
    ADD_DISK="/dev/${local_disk}"    
    mkfs.ext4 -F $ADD_DISK
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    echo -e "n\np\n1\n\n+1200M\np\nw\n" | fdisk "${ADD_DISK}"
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    mkfs.ext3 -F "${ADD_DISK}"1
    CHECK_RESULT $?
    sudo mount "${ADD_DISK}"1 /mnt
    dd if=/dev/zero of=/mnt/test.img bs=1M count=1024 oflag=direct
    find /mnt/test.img
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /mnt
    rm -rf /mnt/test.img
    echo -e "d\np\nw\n" | fdisk "${ADD_DISK}"
    LOG_INFO "Finish environment cleanup."
}

main "$@"
