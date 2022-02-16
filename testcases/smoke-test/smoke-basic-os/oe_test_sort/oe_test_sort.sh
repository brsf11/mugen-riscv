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
    LOG_INFO "Start environment preparation."
    cat  > sort_test.txt  << EOF
hello
world
 openeuler
wc
66
88
   aa
EOF
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    res=$(sort sort_test.txt | head -1)
    CHECK_RESULT $res 66 0 "sort faild"
    sort -c sort_test.txt
    CHECK_RESULT $? 1 0 "sort -c faild"
    sort -d sort_test.txt | head -3 | grep "aa"
    CHECK_RESULT $? 0 0 "sort -d faild"
    sort -g sort_test.txt | head -2 | grep "hello"
    CHECK_RESULT $? 0 0 "sort -g faild"
    sort --help > /dev/null 2>&1
    CHECK_RESULT $? 0 0 "sort help faild"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ./sort_test.txt
    LOG_INFO "Finish environment cleanup!"
}

main $@
