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
# @Desc      :   vfat test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    DNF_INSTALL dosfstools
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    echo -e "n\np\n1\n\n+1200M\np\nw\n" | fdisk /dev/${local_disk}
    CHECK_RESULT $?
    SLEEP_WAIT 2
    mkfs -t vfat "/dev/${local_disk}1"
    CHECK_RESULT $?
    mount "/dev/${local_disk}" /mnt
    dd if=/dev/zero of=/mnt/test.img bs=1M count=1024 oflag=direct
    ls /mnt/test.img
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /mnt/test.img
    umount /mnt
    echo -e "d\np\nw\n" | fdisk /dev/${local_disk}
    LOG_INFO "Finish environment cleanup."
}

main $@
