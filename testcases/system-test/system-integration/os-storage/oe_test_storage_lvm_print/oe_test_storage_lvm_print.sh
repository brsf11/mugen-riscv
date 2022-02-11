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
# @Desc      :   LVM output print display
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    pvcreate -y /dev/${local_disk}
    vgcreate -y openeulertest /dev/${local_disk}
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    line1=$(lvcreate -y -L 50MB -n test3 openeulertest 2>&1 | wc -l)
    lvdisplay | grep "LV Name" | grep test3
    CHECK_RESULT $?
    line2=$(lvcreate -v -L 50MB -n test1 openeulertest 2>&1 | wc -l)
    lvdisplay | grep "LV Name" | grep test1
    CHECK_RESULT $?
    line3=$(lvcreate -vvv -L 50MB -n test2 openeulertest 2>&1 | wc -l)
    lvdisplay | grep "LV Name" | grep test2
    CHECK_RESULT $?
    test "${line1}" -lt "${line2}"
    CHECK_RESULT $?
    test "${line2}" -lt "${line3}"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    lvremove -y openeulertest/test3 openeulertest/test1 openeulertest/test2
    vgremove -y openeulertest
    pvremove /dev/${local_disk}
    LOG_INFO "Finish environment cleanup."
}

main $@
