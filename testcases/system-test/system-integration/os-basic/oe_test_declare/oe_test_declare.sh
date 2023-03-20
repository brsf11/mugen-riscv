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
    LOG_INFO "Start executing testcase!"
    declare -i test1
    test1=114
    echo $test1 | grep 114
    CHECK_RESULT $?
    declare -r test1
    echo $test1 | grep 114
    CHECK_RESULT $?
    declare -i test2
    declare +i test2
    test2="wer"
    echo $test2 | grep wer
    CHECK_RESULT $?
    declare -a cd='([0]="a" [1]="b" [2]="c")'
    echo ${cd[1]} | grep b
    CHECK_RESULT $?
    declare -f | grep gawkpath
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

main $@
