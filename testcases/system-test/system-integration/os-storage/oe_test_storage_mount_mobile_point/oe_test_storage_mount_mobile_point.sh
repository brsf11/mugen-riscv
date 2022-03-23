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
# @Desc      :   Mobile mount point
# #############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    mkfs.xfs -f /dev/"${local_disk2}"
    sleep 2
    mkfs.xfs -f /dev/"${local_disk3}"
    sleep 2
    udevadm settle
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    mount /dev/"${local_disk3}" /mnt
    CHECL_RESULT $?
    mount --make-private /mnt
    CHECK_RESULT $?
    mkdir /mnt/data /mnt/boot
    mount /dev/"${local_disk2}" /mnt/data
    CHECK_RESULT $? 
    findmnt -o TARGET,PROPAGATION /mnt | grep private
    CHECK_RESULT $? 0 0 "private"
    mount --move /mnt/data /mnt/boot
    CHECK_RESULT $? 0 0 "mount move"

    findmnt | grep /dev/"${local_disk2}" | grep "/mnt/boot"
    CHECK_RESULT $? 0 0 "local_disk"
    test -f ${OET_PATH}/libs/locallibs/mugen_log.py
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    mount --move /mnt/boot /mnt/data
    umount /mnt/boot
    umount /mnt/data
    mount --make-share /mnt
    umount /mnt
    SLEEP_WAIT 3
    rm -rf /mnt/data /mnt/boot
    LOG_INFO "Finish environment cleanup."
}

main $@
