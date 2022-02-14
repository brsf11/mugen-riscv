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
# @Date      :   2020-04-28
# @License   :   Mulan PSL v2
# @Desc      :   Print LVM information in different formats
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    pvcreate -y /dev/"${local_disk}"
    vgcreate openeulertest /dev/"${local_disk}"
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    pvs -o pv_name,pv_size | grep "${local_disk}"
    CHECK_RESULT $?
    pvs -o +pv_uuid | grep "PV UUID"
    CHECK_RESULT $?
    pvs -v | grep "${local_disk}"
    CHECK_RESULT $?
    pvs --noheadings -o pv_name | grep "${local_disk}"
    CHECK_RESULT $?
    pvs --separator = | grep "${local_disk}"
    CHECK_RESULT $?
    vgs -o +pv_name | grep openeulertest
    CHECK_RESULT $?
    pvs -o free | grep PFree
    CHECK_RESULT $?
    pvs --segments | grep "${local_disk}"
    CHECK_RESULT $?
    pvs -a /dev/${local_disk}
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    vgremove -y openeulertest
    pvremove /dev/"${local_disk}"
    LOG_INFO "Finish environment cleanup."

}

main "$@"
