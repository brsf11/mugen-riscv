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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020.04-09
# @License   :   Mulan PSL v2
# @Desc      :   Configure keyboard layout test
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start prepare the test environment!"
    key=$(localectl status | grep -i keymap | awk -F : '{print$2}')
    LOG_INFO "End of prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    localectl list-keymaps | grep "nodeadkeys"
    CHECK_RESULT $?
    localectl status | grep "Keymap"
    CHECK_RESULT $?
    localectl set-keymap be-oss
    localectl status | grep -i 'Keymap' | awk -F " " '{print$3}' | grep "be-oss"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    localectl set-keymap ${key}
    LOG_INFO "Finish environment cleanup."
}

main $@
