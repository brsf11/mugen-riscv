#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   xiongneng
# @Contact   :   xiongneng05@uniontech.com
# @Date      :   2023-02-01
# @License   :   Mulan PSL v2
# @Desc      :   Ar command test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    touch a b a.c b.c c.c d.c
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ar rv one.bak a b
    CHECK_RESULT $? 0 0 "check one.bak creation fail"
    ar rv two.bak *.c
    CHECK_RESULT $? 0 0 "check two.bak creation fail"
    ar t two.bak |grep -E "[a.c|b.c|c.c|d.c]"
    CHECK_RESULT $? 0 0 "check file fail"
    ar d two.bak a.c b.c c.c
    CHECK_RESULT $? 0 0 "check file delete fail"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf a b *.c *.bak
    LOG_INFO "End to restore the test environment."
}

main $@