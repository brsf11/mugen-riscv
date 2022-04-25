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
# @Date      :   2020-04-27
# @License   :   Mulan PSL v2
# @Desc      :   Set the label of primary and secondary equipment
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk 2
    mkfs.ext4 -F /dev/${local_disk}
    mkfs.ext4 -F /dev/${local_disk1}
    pvcreate -y /dev/${local_disk} /dev/${local_disk1}
    vgcreate openeulertest /dev/${local_disk} /dev/${local_disk1}
    lvcreate -L 200M -n test openeulertest --persistent y --major 253 --minor 7788 -y
    number=$(pvs -o+pv_used 2>&1 | wc -l)
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    test "${number}" -gt 3
    CHECK_RESULT $?
    lvchange --persistent y --major 253 --minor 7788 openeulertest/test -y
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    lvremove openeulertest/test -y
    vgremove openeulertest -y
    pvremove /dev/${local_disk} /dev/${local_disk1} -y
    LOG_INFO "Finish environment cleanup."
}

main $@
