#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2020-05-07
# @License   :   Mulan PSL v2
# @Desc      :   Shrink logical volume
# ############################################
source ../common/disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    pvcreate -y /dev/${local_disk}
    vgcreate openeulertest /dev/${local_disk} -y
    lvcreate -L 1G -n test openeulertest -y
    mkfs.ext4 /dev/openeulertest/test
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    pvdisplay | grep "PV Name" | grep /dev/${local_disk}
    CHECK_RESULT $?
    vgdisplay | grep "VG Name" | grep openeulertest
    CHECK_RESULT $?
    vgextend openeulertest /dev/${local_disk1} -y
    CHECK_RESULT $?
    lvreduce --resizefs -L 640M openeulertest/test -y
    CHECK_RESULT $?
    lvreduce --resizefs -L 64M openeulertest/test -y
    CHECK_RESULT $?
    lvextend -L +1G /dev/openeulertest/test
    CHECK_RESULT $?
    lvextend -l +100%FREE /dev/openeulertest/test
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    lvremove -y openeulertest/test
    vgremove -y openeulertest
    pvremove -y /dev/${local_disk} /dev/${local_disk1}
    mkfs.ext4 /dev/${local_disk}
    LOG_INFO "Finish environment cleanup."
}

main $@
