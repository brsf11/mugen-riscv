#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   shilei
# @Contact   :   shileib@uniontech.com
# @Date      :   2021-08-19
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-uname
# ############################################
source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."

    uname -s
    CHECK_RESULT $? 0 0 "uname -s display error"

    uname -r
    CHECK_RESULT $? 0 0 "uname -r display error"

    uname -m
    CHECK_RESULT $? 0 0 "uname -m display error"

    uname -a | grep $(uname -r)
    CHECK_RESULT $? 0 0 "uname -a display error"

    uname -n | grep $(hostname)
    CHECK_RESULT $? 0 0 "uname -n display error"

    uname -r | grep -E "^[1-9]+\\.[0-9]+\\.[0-9]+"
    CHECK_RESULT $? 0 0 "check uname -r display error"

    uname --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "uname --help display error"

    LOG_INFO "End to run test."
}

main $@