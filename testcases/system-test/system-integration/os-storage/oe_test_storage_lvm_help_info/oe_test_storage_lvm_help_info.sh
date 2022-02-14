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
# @Desc      :   LVM command help information
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase!"
    lvcreate --help | grep "Create a linear LV"
    CHECK_RESULT $?
    list_array=(lvscan lvs lvremove pvcreate pvremove pvscan pvs vgcreate vgremove vgscan)
    for cmd in "${list_array[@]}"; do
        ${cmd} --help
        CHECK_RESULT $?
    done
    LOG_INFO "End of testcase execution!"
}

main $@
