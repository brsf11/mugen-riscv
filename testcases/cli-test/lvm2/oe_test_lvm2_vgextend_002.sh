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
    pvcreate -y /dev/${local_disk} /dev/${local_disk1}
    CHECK_RESULT $? 0 0 "failed to creat PV"
    pvs | grep "/dev/${local_disk}" && pvs | grep "/dev/${local_disk1}"
    CHECK_RESULT $? 0 0 "failed to creat PV"
    vgcreate test /dev/${local_disk}
    CHECK_RESULT $? 0 0 "failed to creat VG"
    vgdisplay | grep "VG Name" | grep "test"
    CHECK_RESULT $? 0 0 "failed to creat PV"
    vgextend --dataalignment 3 test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to vgextend --dataalignment"
    pvs | grep "/dev/${local_disk1}" | grep "test"
    CHECK_RESULT $? 0 0 "failed to creat PV"
    vgremove -f test
    vgcreate test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $? 0 0 "failed to creat VG"
    vgextend --dataalignmentoffset 3 test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to vgextend --dataalignmentoffset"
    vgremove -f test
    vgcreate test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $? 0 0 "failed to creat VG"
    vgextend --reportformat basic test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to vgextend --reportformat basic"
    vgextend --help | grep "Add physical volumes to a volume group"
    CHECK_RESULT $? 0 0 "failed to vgextend --help"
    vgextend --version | grep "LVM version"
    CHECK_RESULT $? 0 0 "failed to test extend version"
    vgremove -f test
    vgcreate test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $? 0 0 "failed to creat VG"
    vgextend -t test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to vgextend -t"
    vgremove -f test
    vgcreate test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $?
    vgextend -t test /dev/${local_disk1} 2>&1 | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to extend VG -t"
    vgremove -f test
    vgcreate test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $? 0 0 "failed to creat VG"
    vgextend -q test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to extend VG -q"
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
