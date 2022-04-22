#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   duanxuemin
# @Contact   :   duanxuemin_job@163.com
# @Date      :   2022-04-09
# @License   :   Mulan PSL v2
# @Desc      :   lvm2 command test
# ############################################
source ./common/disk_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL lvm2
    check_free_disk
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    pvcreate -y /dev/${local_disk}
    CHECK_RESULT $?
    pvdisplay | grep "PV UUID"
    pvcreate -y /dev/${local_disk} --setphysicalvolumesize 30MB | grep "successfully created"
    CHECK_RESULT $?
    pvs | sed -n 3p | awk {'print$4'} | grep "30.00m"
    CHECK_RESULT $?
    pvcreate -y /dev/${local_disk} --dataalignment 10MB | grep "successfully created"
    CHECK_RESULT $?
    pvcreate -y /dev/${local_disk} --metadataignore y | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --metadatatype lvm2 | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --zero y | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --dataalignmentoffset 1MB | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --bootloaderareasize 5MB | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --labelsector 3 | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --pvmetadatacopies 1 | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --metadatasize 10MB | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --metadataignore y | grep "successfully created"
    CHECK_RESULT $?
    LOG_INFO "End executing testcase!"
}
function post_test() {
    LOG_INFO "Start environment cleanup."
    pvremove -f /dev/${local_disk}
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
