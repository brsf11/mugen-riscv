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
    CHECK_RESULT $? 0 0 "create PV failed"
    pvs | grep "/dev/${local_disk}"
    CHECK_RESULT $? 0 0 "create PV failed"
    vgcreate test /dev/${local_disk}
    CHECK_RESULT $? 0 0 "create VG failed"
    vgdisplay | grep "VG Name" | grep "test"
    CHECK_RESULT $? 0 0 "create VG failed"
    vgexport test | grep "successfully exported"
    CHECK_RESULT $? 0 0 "failed to export VG test"
    vgimport test
    vgexport -y test | grep "successfully exported"
    CHECK_RESULT $? 0 0 "failed to export VG test"
    vgimport test
    vgexport --reportformat basic test | grep "successfully exported"
    CHECK_RESULT $? 0 0 "failed to export VG test --reportformat basic"
    vgimport test
    vgexport --reportformat json test | grep "successfully exported"
    CHECK_RESULT $? 0 0 "failed to export VG test --reportformat basic"
    vgimport test
    vgexport -v test | grep "successfully exported"
    CHECK_RESULT $? 0 0 "failed to export VG test -v"
    vgimport test
    vgexport -t test | grep "successfully exported"
    CHECK_RESULT $? 0 0 "failed to export VG test -t"
    vgimport test
    vgexport -q test | grep "successfully exported"
    CHECK_RESULT $? 0 0 "failed to export VG test -q"
    vgexport --help | grep "Unregister volume group(s) from the system"
    CHECK_RESULT $? 0 0 "vgexport --help failed"
    vgextend --version | grep "LVM version"
    CHECK_RESULT $? 0 0 "failed to test vgextend version"
    vgimport test
    vgexport -d test | grep "successfully exported"
    CHECK_RESULT $? 0 0 "failed to export VG test -d"
    LOG_INFO "End executing testcase!"
}
function post_test() {
    LOG_INFO "Start environment cleanup."
    vgimport test
    vgremove -f test
    pvremove -f /dev/${local_disk}
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
