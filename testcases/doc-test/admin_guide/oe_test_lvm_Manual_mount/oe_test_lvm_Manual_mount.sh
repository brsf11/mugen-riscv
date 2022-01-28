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
# @Author    :   duanxuemin
# @Contact   :   52515856@qq.com
# @Date      :   2020-04-27
# @License   :   Mulan PSL v2
# @Desc      :   Create LV
# ############################################
source ../common/disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    pvcreate -y /dev/${local_disk} /dev/${local_disk1}
    vgcreate -y openeulertest /dev/${local_disk} /dev/${local_disk1}
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    pvdisplay | grep "PV Name" | grep /dev/${local_disk}
    CHECK_RESULT $?
    pvdisplay | grep "PV Name" | grep /dev/${local_disk1}
    CHECK_RESULT $?
    vgdisplay | grep "VG Name" | grep openeulertest
    CHECK_RESULT $?
    lvcreate -y -L 50MB -n test openeulertest
    CHECK_RESULT $?
    lvdisplay | grep "LV Name" | grep test
    CHECK_RESULT $?
    mkfs.ext4 -F /dev/openeulertest/test
    CHECK_RESULT $?
    mount /dev/openeulertest/test /mnt
    CHECK_RESULT $?
    df | grep openeulertest-test
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /dev/openeulertest/test
    lvremove -y openeulertest/test
    vgremove -y openeulertest
    pvremove -y /dev/${local_disk} /dev/${local_disk1}
    mkfs.ext4 /dev/${local_disk1}
    mkfs.ext4 /dev/${local_disk}
    LOG_INFO "Finish environment cleanup."
}

main $@
