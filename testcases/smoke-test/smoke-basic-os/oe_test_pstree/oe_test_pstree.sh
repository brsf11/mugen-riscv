#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   dengailing
# @Contact   :   dengailing@uniontech.com
# @Date      :   2022-12-13
# @License   :   Mulan PSL v2
# @Desc      :   test pstree
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    pstree -V 
    CHECK_RESULT $? 0 0 "pstree -V fail"
    pstree -a | grep 'systemd' 
    CHECK_RESULT $? 0 0 "pstree -a fail"
    pstree -A | grep 'systemd-+-'
    CHECK_RESULT $? 0 0 "pstree -A fail"
    pstree -p | grep 'systemd(1)'
    CHECK_RESULT $? 0 0 "pstree -p fail"
    pstree -g 
    CHECK_RESULT $? 0 0 "pstree -g fail"
    pstree -s 
    CHECK_RESULT $? 0 0 "pstree -s fail"
    pstree -t 
    CHECK_RESULT $? 0 0 "pstree -t fail"
    pstree -u 
    CHECK_RESULT $? 0 0 "pstree -u fail"
    LOG_INFO "Finish test!"
}

main "$@"

