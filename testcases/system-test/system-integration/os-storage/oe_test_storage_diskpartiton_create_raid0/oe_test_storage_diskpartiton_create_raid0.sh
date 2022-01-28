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
# @Desc      :   Create raid0
# ############################################
source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    check_free_disk
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL mdadm
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    mdadm --create --auto=yes /dev/md0 --level=0 --raid-device=3 /dev/${local_disk} /dev/${local_disk1} /dev/${local_disk2} <<EOF
y
EOF
    CHECK_RESULT $?
    lsblk | grep -c md0 | grep 3
    mdadm --detail /dev/md0 | grep "Raid Device" | awk -F ':' '{print$2}' | grep 3
    CHECK_RESULT $?
    mdadm --stop /dev/md0
    CHECK_RESULT $?

    mdadm --misc --zero-superblock /dev/${local_disk} /dev/${local_disk1} /dev/${local_disk2}
    lsblk | grep md0
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    mkfs.ext4 -F ${local_disk}
    SLEEP_WAIT 2
    mkfs.ext4 -F ${local_disk1}
    SLEEP_WAIT 2
    mkfs.ext4 -F ${local_disk2}
    SLEEP_WAIT 2
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main "$@"
