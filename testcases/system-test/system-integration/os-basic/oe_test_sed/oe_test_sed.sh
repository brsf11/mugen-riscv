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

function pre_test() {
    LOG_INFO "Start environment preparation."
    ls /tmp/test && rm -rf /tmp/test
    for ((i=1;i<=10;i+=1))
    do
        echo $i >> /tmp/test
    done
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    sed -i 3a\newLine /tmp/test
    grep newLine /tmp/test
    CHECK_RESULT $? 0 0 "append new line failed"
    nl /tmp/test | sed '4d' | grep "newLine"
    CHECK_RESULT $? 0 1 "delete line failed"
    nl /tmp/test | sed '2i this is add_word' | grep "this"
    CHECK_RESULT $? 0 0 "add word when display failed"
    nl /tmp/test | sed '2,5c 2--5' | grep -w "2--5"
    CHECK_RESULT $? 0 0 "replace word failed"
    nl /tmp/test | sed -n '2,5p' | grep -E [2-5]
    CHECK_RESULT $? 0 0 "display part of document failed"
    count=$(nl /tmp/test |sed '/1/p' | grep -c '1')
    [ $count -eq 6 ]
    CHECK_RESULT $? 0 0 "sed find text failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/test
    LOG_INFO "End to restore the test environment."
}

main "$@"