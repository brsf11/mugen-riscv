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
# @Desc      :   Track and query the status of lvmsnap volumes
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    pvcreate -y /dev/${local_disk}
    vgcreate openeulertest /dev/${local_disk}
    lvcreate -y -L 50MB -n test openeulertest
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    lvcreate -L 100M -T openeulertest/mythinpool -y
    CHECK_RESULT $?
    lvdisplay | grep "mythinpool"
    CHECK_RESULT $?
    lvcreate -V 1G -T openeulertest/mythinpool -n thinvolume -y
    CHECK_RESULT $?
    lvdisplay | grep "thinvolume"
    lvs -H -o name,full_ancestors,full_descendants | grep "LV"
    CHECK_RESULT $?
    lvremove -y openeulertest/mythinpool
    CHECK_RESULT $?
    lvdisplay | grep "mythinpool"
    CHECK_RESULT $? 1
    lvremove -y openeulertest/test
    lvdisplay | grep test
    CHECK_RESULT $? 1
    lvs -H -o name,full_ancestors,full_descendants | grep "LV"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    vgremove -y openeulertest
    pvremove /dev/${local_disk}
    LOG_INFO "Finish environment cleanup."
}

main "$@"
