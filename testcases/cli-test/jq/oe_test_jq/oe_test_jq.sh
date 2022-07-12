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
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/21
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of jq command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL jq
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    jq --help | grep "Usage:"
    CHECK_RESULT $?
    jq --version | grep "jq-"
    CHECK_RESULT $?
    jq -c "." test.json | grep "url"
    CHECK_RESULT $?
    jq -n "." test.json | grep "null"
    CHECK_RESULT $?
    jq -e "." test.json | grep "  "
    CHECK_RESULT $?
    jq -s "." test.json
    CHECK_RESULT $?
    jq -r "." test.json
    CHECK_RESULT $?
    jq -R "." test.json | grep '\\'
    CHECK_RESULT $?
    jq -C "." test.json
    CHECK_RESULT $?
    jq -M "." test.json
    CHECK_RESULT $?
    jq -S "." test.json
    CHECK_RESULT $?
    jq --tab "." test.json
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
