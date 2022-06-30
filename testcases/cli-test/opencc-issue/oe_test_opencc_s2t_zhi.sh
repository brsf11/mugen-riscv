#!/usr/bin/bash

# Copyright (c) 2020. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2021/01/25
# @License   :   Mulan PSL v2
# @Desc      :   About "只" simple to complex
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL opencc
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    echo '是只鸟' | opencc -c s2t | grep '是隻鳥'
    CHECK_RESULT $?
    echo '只有' | opencc -c s2t | grep '只有'
    CHECK_RESULT $?
    echo '可是只有他才能完成这个任务' | opencc -c s2t | grep '可是隻有他才能完成這個任務'
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE 1
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
