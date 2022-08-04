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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-cd
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    current_path=$(
        cd "$(dirname $0)" || exit 1
        pwd
    )
    test -d example && rm -rf example

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    mkdir example
    cd example
    CHECK_RESULT $? 0 0 "run cd example fail"
    pwd | grep "example"
    CHECK_RESULT $? 0 0 "after cd example not change to example dir"
    cd ..
    CHECK_RESULT $? 0 0 "run cd .. fail"
    pwd | grep "${current_path}"
    CHECK_RESULT $? 0 0 "after cd .. not change to current_path dir"
    cd -
    CHECK_RESULT $? 0 0 "run cd - fail"
    pwd | grep "example"
    CHECK_RESULT $? 0 0 "after cd - not change to example dir"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    cd "${current_path}"
    rm -rf example

    LOG_INFO "End to restore the test environment."
}

main $@
