#!/usr/bin/bash

#Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Configure keyboard layout test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    now_keymap=$(localectl status | grep -i 'Keymap' | awk -F " " '{print$3}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    localectl list-keymaps | grep "nodeadkeys"
    CHECK_RESULT $?
    localectl set-keymap be-oss
    CHECK_RESULT $?
    localectl status | grep -i 'Keymap' | awk -F " " '{print$3}' | grep "be-oss"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    localectl set-keymap "${now_keymap}"
    LOG_INFO "End to restore the test environment."
}

main "$@"
