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
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/29
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of kmod command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    kmod -h | grep -E "Usage:|kmod \[options\]"
    CHECK_RESULT $?
    kmod -V | grep -i "kmod version"
    CHECK_RESULT $?
    kmod help | grep -E "Usage:|help \[options\]"
    CHECK_RESULT $?
    kmod list | grep "[a-zA-Z0-9]"
    CHECK_RESULT $?
    kmod static-nodes | grep -E "Module|Device node"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

main $@
