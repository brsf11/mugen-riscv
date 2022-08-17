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
    vgcreate test /dev/${local_disk}
    CHECK_RESULT $?
    pvchange -x n /dev/${local_disk} 2>&1 | grep "Physical volume \"/dev/${local_disk}\" changed"
    CHECK_RESULT $?
    pvchange --addtag gh /dev/${local_disk} 2>&1 | grep "Physical volume \"/dev/${local_disk}\" changed"
    CHECK_RESULT $?
    pvchange --deltag gh /dev/${local_disk} 2>&1 | grep "Physical volume \"/dev/${local_disk}\" changed"
    CHECK_RESULT $?
    pvchange --allocatable y /dev/${local_disk} 2>&1 | grep "Physical volume \"/dev/${local_disk}\" changed"
    CHECK_RESULT $?
    pvchange --version | grep "LVM version"
    CHECK_RESULT $?
    pvchange --help | grep "Change attributes of physical volume"
    CHECK_RESULT $?
    pvchange --longhelp | grep "Change attributes of physical volume"
    CHECK_RESULT $?
    LOG_INFO "End executing testcase!"
}
function post_test() {
    LOG_INFO "Start environment cleanup."
    vgremove test -f
    pvremove -f /dev/${local_disk}
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
