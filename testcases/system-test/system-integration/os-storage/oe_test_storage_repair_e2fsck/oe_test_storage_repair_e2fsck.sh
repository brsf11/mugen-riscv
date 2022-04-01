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
# @Desc      :   Check ext2, ext3, ext4 file system with e2fsck
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    check_free_disk
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    echo -e "n\np\n1\n\n+20M\nn\np\n2\n\n+20M\nn\np\n3\n\n+20M\np\nw\n" | fdisk /dev/${local_disk}
    mkfs.ext2 -F "/dev/${local_disk}"1
    SLEEP_WAIT 2
    mkfs.ext3 -F "/dev/${local_disk}"2
    SLEEP_WAIT 2
    mkfs.ext4 -F "/dev/${local_disk}"3
    SLEEP_WAIT 2
    udevadm settle
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    e2fsck -n "/dev/${local_disk}"1
    CHECK_RESULT $?
    e2fsck -n "/dev/${local_disk}"2
    CHECK_RESULT $?
    e2fsck -n "/dev/${local_disk}"3
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    echo -e "d\n\nd\n\nd\n\np\nw\n" | fdisk /dev/${local_disk}
    LOG_INFO "Finish environment cleanup."
}

main $@
