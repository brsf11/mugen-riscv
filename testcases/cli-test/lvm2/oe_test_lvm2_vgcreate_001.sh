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
    version_id=$(cat /etc/os-release | grep "VERSION_ID" | awk -F "=" {'print$NF'} | awk -F "\"" {'print$2'})
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    pvcreate -y /dev/${local_disk} /dev/${local_disk1} /dev/${local_disk2}
    CHECK_RESULT $?
    pvck -v /dev/${local_disk} | grep "Found label on /dev/${local_disk}"
    CHECK_RESULT $?
    vgcreate test /dev/${local_disk} --autobackup y | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate test /dev/${local_disk} --maxlogicalvolumes 3 | grep "successfully created"
    CHECK_RESULT $?
    lvcreate -L 0.1MB -n lv test | grep "created"
    CHECK_RESULT $?
    lvcreate -L 0.1MB -n lv1 test | grep "created"
    CHECK_RESULT $?
    lvcreate -L 0.1MB -n lv2 test | grep "created"
    CHECK_RESULT $?
    lvcreate -L 0.1MB -n lv3 test | grep "Maximum number of logical volumes (3) reached in volume group test"
    CHECK_RESULT $? 1
    CHECK_RESULT $?
    vgremove test -f
    vgcreate --maxphysicalvolumes 2 test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgextend test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $?
    vgextend test /dev/${local_disk2} 2>&1 | grep "max 2 physical volume"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate test /dev/${local_disk} --metadatatype lvm2 | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate test /dev/${local_disk} --physicalextentsize 2 | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate -f test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate --zero y test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate --addtag lh test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate --alloc contiguous test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    touch /etc/lvm/profile/lh.profile
    vgcreate --metadataprofile lh test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate --labelsector 1 test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate --metadatasize 1 test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate --pvmetadatacopies 0 test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate --vgmetadatacopies all test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate --reportformat basic test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate --dataalignment 2 test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    vgcreate --dataalignmentoffset 2 test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgremove test -f
    version_id=$(cat /etc/os-release | grep "VERSION_ID" | awk -F "=" {'print$NF'})
    if [${version_id} = "22.03"]; then
        vgcreate --setautoactivation y test /dev/${local_disk} | grep "successfully created"
        CHECK_RESULT $?
    fi
    vgcreate --help | grep "Create a volume group"
    CHECK_RESULT $?
    LOG_INFO "End executing testcase!"
}
function post_test() {
    LOG_INFO "Start environment cleanup."
    vgremove test -f
    pvremove -f /dev/${local_disk} /dev/${local_disk1} /dev/${local_disk2}
    rm -rf /etc/lvm/profile/lh.profile
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
