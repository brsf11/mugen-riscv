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
# @Date      :   2022-11-30
# @License   :   Mulan PSL v2
# @Desc      :   package procps-ng-sysctl test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"


function run_test() {
    LOG_INFO "Start testing..."
    sysctl -p
    CHECK_RESULT $? 0 0 "sysctl -p Echo information error"
    sysctl -n  net.ipv4.tcp_syncookies
    CHECK_RESULT $? 0 0 "sysctl -n net.ipv4.tcp_syncookies Echo information error" 
    sysctl -w net.ipv4.tcp_syncookies = 0
    CHECK_RESULT $? 0 1 "sysctl -w  Echo information error"
    sysctl -n  net.ipv4.tcp_syncookies
    CHECK_RESULT $? 0 0 "sysctl -n  Echo information error"
    sysctl -V
    CHECK_RESULT $? 0 0 "sysctl -V Echo information error"
    sysctl -h
    CHECK_RESULT $? 0 0 "sysctl -h  Echo information error"
    LOG_INFO "Finish test!"
}


main $@
