#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.


source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    expr length "test" | grep 4
    CHECK_RESULT $?
    expr index "satrasara"  a | grep 2
    CHECK_RESULT $?
    expr 1 + 1 | grep 2
    CHECK_RESULT $?
    expr substr "abcdef" 2 3 | grep -w "bcd"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

main "$@"