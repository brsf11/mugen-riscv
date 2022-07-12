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
    pvcreate -y /dev/${local_disk}
    CHECK_RESULT $? 0 0 "create PV failed"
    pvs | grep "/dev/${local_disk}"
    CHECK_RESULT $? 0 0 "create PV failed"
    vgcreate test /dev/${local_disk}
    CHECK_RESULT $? 0 0 "create VG failed"
    vgdisplay | grep "VG Name" | grep "test"
    CHECK_RESULT $? 0 0 "create VG failed"
    vgchange --logicalvolume 1 test | grep "Volume group \"test\" successfully changed"
    CHECK_RESULT $? 0 0 "vgchange logicalvolume size failed"
    lvcreate -L 0.1MB -n lv test | grep "created"
    CHECK_RESULT $? 0 0 "create LV failed"
    lvcreate -L 0.1MB -n lv1 test 2>&1 | grep "Maximum number of logical volumes (1) reached"
    CHECK_RESULT $? 0 0 "Maximum number of logical volumes (1) reached"
    vgchange --maxphysicalvolumes 1 test 2>&1 | grep "Volume group \"test\" successfully changed"
    CHECK_RESULT $? 0 0 "set maxphysicalvolumes failed"
    pvcreate -y /dev/${local_disk1}
    CHECK_RESULT $? 0 0 "create PV failed"
    vgextend test /dev/${local_disk1} 2>&1 | grep "PV /dev/${local_disk1} cannot be added to VG test"
    CHECK_RESULT $? 0 0 "vgextend failed"
    lvremove -f lv test | grep "successfully removed"
    CHECK_RESULT $? 0 0 "lvremove failed"
    vgchange -u test | grep "Volume group \"test\" successfully changed"
    CHECK_RESULT $? 0 0 "vgchange -u failed"
    vgchange --resizeable n test | grep "Volume group \"test\" successfully changed"
    CHECK_RESULT $? 0 0 "vgchange --resizeable no failed"
    vgchange --resizeable y test | grep "Volume group \"test\" successfully changed"
    CHECK_RESULT $? 0 0 "vgchange --resizeable yes failed"
    vgchange --addtag tag test | grep "Volume group \"test\" successfully changed"
    CHECK_RESULT $? 0 0 "vgchange add tag failed"
    vgchange --deltag tag test | grep "Volume group \"test\" successfully changed"
    CHECK_RESULT $? 0 0 "vgchange del tag failed"
    vgchange --vgmetadatacopies all test | grep "Volume group \"test\" successfully changed"
    CHECK_RESULT $? 0 0 "vgchange --vgmetadatacopies all failed"
    if [${version_id} = "22.03"]; then
        vgchange --setautoactivation n test | grep "Volume group \"test\" successfully changed"
        CHECK_RESULT $? 0 0 "vgchange --setautoactivation no failed"
        vgchange --setautoactivation y test | grep "Volume group \"test\" successfully changed"
        CHECK_RESULT $? 0 0 "vgchange --setautoactivation yes failed"
    fi
    LOG_INFO "End executing testcase!"
}
function post_test() {
    LOG_INFO "Start environment cleanup."
    vgremove -f test
    pvremove -f /dev/${local_disk} /dev/${local_disk1}
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
