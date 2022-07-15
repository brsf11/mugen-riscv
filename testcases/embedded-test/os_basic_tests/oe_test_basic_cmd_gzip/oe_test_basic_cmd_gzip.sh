#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Desc      :   File system common command test-gzip
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    current_path=$(
        cd "$(dirname $0)" || exit 1
        pwd
    )
    cd /tmp || exit 1
    touch test11
    gzip -9 test11

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    test -f test11
    CHECK_RESULT $? 1 0 "check test11 fail"
    gzip -d test11.gz
    CHECK_RESULT $? 0 0 "run gzip -d fail"
    test -f test11
    CHECK_RESULT $? 0 0 "check test11 fail"
    gzip --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check gzip help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf /tmp/test11
    cd ${current_path} || exit 1

    LOG_INFO "End to restore the test environment."
}

main $@
