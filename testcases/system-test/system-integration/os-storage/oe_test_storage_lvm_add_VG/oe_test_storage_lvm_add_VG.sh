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
# @Desc      :   Add disks to VG
# ############################################
source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    check_free_disk
    mkfs.ext4 -F /dev/${local_disk}
    mkfs.ext4 -F /dev/${local_disk1}
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    pvcreate -y /dev/${local_disk} /dev/${local_disk1}
    vgcreate openeulertest /dev/${local_disk}
    lvcreate -L 50MB -n test openeulertest -y
    number=$(pvs -o+pv_used 2>&1 | wc -l)
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    test ${number} -gt 3
    CHECK_RESULT $?
    vgextend openeulertest /dev/${local_disk1} -y
    pvmove /dev/${local_disk} /dev/${local_disk1}
    CHECK_RESULT $?
    pvs -o+pv_used | grep ${local_disk} | grep 0
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    lvremove -y /dev/openeulertest/test
    vgremove -y openeulertest
    pvremove /dev/${local_disk}
    pvremove /dev/${local_disk1}
    LOG_INFO "Finish environment cleanup."
}

main $@
