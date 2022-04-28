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
    pvs | grep "/dev/${local_disk}"
    CHECK_RESULT $?
    pvdisplay | grep "PV Name" | grep "${local_disk}"
    CHECK_RESULT $?
    pvdisplay -c 2>&1 | grep "\"/dev/${local_disk}\" is a new physical volume"
    CHECK_RESULT $?
    pvdisplay -m | grep "PV Name" | grep "${local_disk}"
    CHECK_RESULT $?
    pvdisplay -s | grep "Device \"/dev/${local_disk}\" has a capacity"
    CHECK_RESULT $?
    pvdisplay -C -a | grep "/dev/${local_disk}"
    CHECK_RESULT $?
    pvdisplay -C --aligned | grep "/dev/${local_disk}"
    CHECK_RESULT $?
    pvdisplay -C --binary | grep "/dev/${local_disk}"
    CHECK_RESULT $?
    pvdisplay --configreport log | grep "PV Name" | grep "${local_disk}"
    CHECK_RESULT $?
    pvdisplay --foreign 2>&1 | grep "\"/dev/${local_disk}\" is a new physical volume"
    CHECK_RESULT $?
    pvdisplay --ignorelockingfailure 2>&1 | grep "\"/dev/${local_disk}\" is a new physical volume"
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
