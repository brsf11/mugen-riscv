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
# @Desc      :   Reduce LV
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
    lvdisplay | grep "LV Name" | grep test
    CHECK_RESULT $?
    lvreduce --resizefs -L 500MB openeulertest/test -y
    CHECK_RESULT $?
    lvreduce --resizefs -L 64MB openeulertest/test -y
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    lvremove -y openeulertest/duan
    vgremove -y openeulertest
    pvremove /dev/${local_disk}
    mkfs.ext4 /dev/${local_disk}
    LOG_INFO "Finish environment cleanup."
}

main $@
