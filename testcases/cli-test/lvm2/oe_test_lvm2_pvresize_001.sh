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
# @Desc      :   lvm2 command test-pvresize
# ############################################
source ./common/disk_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL lvm2
    check_free_disk
    version_id=$(cat /etc/os-release | grep "VERSION_ID" | awk -F "=" {'print$NF'} | awk -F "\"" {'print$2'})
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    pvcreate -y /dev/${local_disk}
    CHECK_RESULT $?
    pvresize -y /dev/${local_disk} --setphysicalvolumesize 50MB 2>&1 | grep "Physical volume \"/dev/${local_disk}\" changed"
    CHECK_RESULT $?
    pvs | sed -n 3p | awk {'print$5'} | grep "50.00m"
    CHECK_RESULT $?
    pvresize -y /dev/${local_disk} --reportformat basic | grep "Physical volume \"/dev/${local_disk}\" changed"
    CHECK_RESULT $?
    pvresize -y /dev/${local_disk} --driverloaded y | grep "Physical volume \"/dev/${local_disk}\" changed"
    CHECK_RESULT $?
    pvresize --version | grep "LVM version"
    CHECK_RESULT $?
    pvresize --longhelp | grep "Common variables for lvm"
    CHECK_RESULT $?
    pvresize -y /dev/${local_disk} --nolocking | grep "Physical volume \"/dev/${local_disk}\" changed"
    CHECK_RESULT $?
    pvresize -y /dev/${local_disk} -q | grep "Physical volume \"/dev/${local_disk}\" changed"
    CHECK_RESULT $?
    pvresize -y /dev/${local_disk} --verbose | grep "Physical volume \"/dev/${local_disk}\" changed"
    CHECK_RESULT $?
    if [${version_id} = "22.03"]; then
        pvresize -y /dev/${local_disk} --nohints | grep "Physical volume \"/dev/${local_disk}\" changed"
        CHECK_RESULT $?
    fi
    LOG_INFO "End executing testcase!"
}
function post_test() {
    LOG_INFO "Start environment cleanup."
    pvremove -f /dev/${local_disk}
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
