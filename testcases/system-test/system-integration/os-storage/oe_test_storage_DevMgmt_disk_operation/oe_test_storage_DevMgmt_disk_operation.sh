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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-04-27
# @License   :   Mulan PSL v2
# @Desc      :   Disk operation:parted/fdisk
# ############################################
source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    check_free_disk
    DISK_A="/dev/${local_disk}"
    ADD_DISK="/dev/${local_disk1}"
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    mkfs.ext4 -F ${DISK_A}
    mkfs.ext4 -F ${ADD_DISK}
    fdisk ${ADD_DISK} <<EOF
n
p
1

+200M
w
EOF
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    parted ${DISK_A} >log 2>&1 <<EOF
print
select ${ADD_DISK}
print
quit
EOF
    grep -iE 'error|fail' log
    CHECK_RESULT $? 1
    grep "Using ${ADD_DISK}" log
    CHECK_RESULT $?
    grep ${ADD_DISK} -A 9 log | grep Table
    CHECK_RESULT $?
    parted ${ADD_DISK} >log 2>&1 <<EOF
mklabel msdos
mklabel gpt
mkpart primary 400MiB 600MiB
p
quit
EOF
    grep -iE 'error|fail' log
    CHECK_RESULT $? 1
    udevadm settle
    CHECK_RESULT $(cat /proc/partitions | grep -iE "${local_disk}|${local_disk1}1|${local_disk1}2" | wc -l) 3

    fdisk ${ADD_DISK} >log 2>&1 <<EOF
type
1
30
type
1
83
print
quit
EOF
    grep -iE 'error|fail' log
    CHECK_RESULT $? 1
    parted ${ADD_DISK} >log 2>&1 <<EOF
print
resizepart 1 300M
print
quit
EOF
    grep -iE 'error|fail' log
    CHECK_RESULT $? 1
    test $(cat /proc/partitions | grep -i ${local_disk1}1 | awk '{print$3}') -gt 204800
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    fdisk "${ADD_DISK}" <<EOF
d
1
d
w
EOF
    rm -rf log
    LOG_INFO "Finish environment cleanup."
}

main "$@"
