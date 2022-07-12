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
    version_id=$(cat /etc/os-release | grep "VERSION_ID" | awk -F "=" {'print$NF'})
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    pvcreate /dev/${local_disk} -y --norestorefile | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --setphysicalvolumesize 50MB | grep "successfully created"
    CHECK_RESULT $?
    pvs | sed -n 3p | awk {'print$4'} | grep "50.00m"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --setphysicalvolumesize 50MB --reportformat basic | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --setphysicalvolumesize 50MB --reportformat json | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --verbose | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --driverloaded y | grep "successfully created"
    CHECK_RESULT $?
    pvcreate /dev/${local_disk} -y --nolocking | grep "successfully created"
    CHECK_RESULT $?
    pvcreate --longhelp | grep "LV"
    CHECK_RESULT $?
    pvcreate --version | grep "LVM version"
    CHECK_RESULT $?
    if [${version_id} = "22.03"]; then
        pvcreate /dev/${local_disk} -y --nohints | grep "successfully created"
        CHECK_RESULT $?
    fi
    LOG_INFO "End executing testcase!"
}
function post_test() {
    LOG_INFO "Start environment cleanup."
    pvremove -f /dev/${local_disk}
    DNF_REMOVE lvm2
    LOG_INFO "Finish environment cleanup."
}

main $@
