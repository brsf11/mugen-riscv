#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##############################################
# @Author    :   suhang
# @Contact   :   suhangself@163.com
# @Date      :   2022-01-05
# @License   :   Mulan PSL v2
# @Desc      :   Video coding tool x265
# ##############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL x265
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    x265 -h | grep "Options"
    CHECK_RESULT $? 0 0 "Help information printing failed"
    x265 -V 2>&1 | grep -E "[0-9]"
    CHECK_RESULT $? 0 0 "Version information printing failed"
    x265 --input test.y4m -o file0 && test -f file0
    CHECK_RESULT $? 0 0 "Check file0 failed"
    x265 --input test.y4m -o file0 --log-level warning 2>&1 | grep "warning"
    CHECK_RESULT $? 0 0 "Check warning failed"
    x265 --input test.y4m -o file0 --fps 66 2>&1 | grep "fps 66000"
    CHECK_RESULT $? 0 0 "Check fps 66000 failed"
    x265 --input test.y4m -o file0 --frames 123 2>&1 | grep "frames 0 - 122"
    CHECK_RESULT $? 0 0 "Check frames 122 failed"
    x265 --input test.y4m -o file0 --seek 5 2>&1 | grep "frames 5"
    CHECK_RESULT $? 0 0 "Check frames 5 failed"
    x265 --input test.y4m -o file1 -D 10 && test -f file1
    CHECK_RESULT $? 0 0 "Check file1 failed"
    x265 --input test.y4m -o file2 --no-progress && test -f file2
    CHECK_RESULT $? 0 0 "Check file2 failed"
    x265 --input test.y4m -o file3 --csv file3_csv && test -f file3_csv
    CHECK_RESULT $? 0 0 "Check file3 failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf file*
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
