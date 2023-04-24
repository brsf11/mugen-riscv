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
# @Author    :   gaoshuaishuai
# @Contact   :   gaoshuaishuai@uniontech.com
# @Date      :   2022-11-28
# @License   :   Mulan PSL v2
# @Desc      :   package procps-ng-uptime test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    uptime -V
    CHECK_RESULT $? 0 0 "uptime -V Echo information error"
    uptime -h
    CHECK_RESULT $? 0 0 "uptime -h Echo information error" 
    uptime -s
    CHECK_RESULT $? 0 0 "uptime -s Echo information error"
    uptime -p
    CHECK_RESULT $? 0 0 "uptime -p Echo information error"
    uptime
    CHECK_RESULT $? 0 0 "uptime  Echo information error"
    LOG_INFO "Finish test!"
}

main $@
