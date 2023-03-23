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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/07/07
# @License   :   Mulan PSL v2
# @Desc      :   Test ip rule list and show
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ip rule list table main | grep main
    CHECK_RESULT $? 0 0 "Failed to display main"
    ip rule list table main | grep -E "local|default"
    CHECK_RESULT $? 0 1 "Not just the main list"
    ip rule show | grep -A 3 local | grep -A 2 main | grep default
    CHECK_RESULT $? 0 0 "Incomplete display"
    LOG_INFO "End to run test."
}

main "$@"
