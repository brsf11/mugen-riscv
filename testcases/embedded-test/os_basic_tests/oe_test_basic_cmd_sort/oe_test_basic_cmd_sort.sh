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
# @Author    :   wangpeng
# @Contact   :   wangpengb@uniontech.com
# @Date      :   2022.2.16
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-sort
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    old_lang=${LANG}
    export LANG=C
    cat  > sort_test.txt  << EOF
hello
world
 openeuler
wc
66
88
   aa
xY
Yx
EOF

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    res=$(sort sort_test.txt | head -1)
    CHECK_RESULT $res aa 0 "sort faild"
    sort -c sort_test.txt
    CHECK_RESULT $? 1 0 "sort -c faild"
    sort -d sort_test.txt | head -1 | grep "aa"
    CHECK_RESULT $? 0 0 "sort -d faild"
    sort -g sort_test.txt | head -3 | grep "Yx"
    CHECK_RESULT $? 0 0 "sort -g faild"
    sort -f sort_test.txt | head -8 | grep "xY"
    CHECK_RESULT $? 0 0 "sort -f faild"
    sort --help 2>&1 | grep "Usage:"
    CHECK_RESULT $? 0 0 "sort help faild"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf ./sort_test.txt
    export LANG=${old_lang}

    LOG_INFO "End to restore the test environment."
}

main $@
