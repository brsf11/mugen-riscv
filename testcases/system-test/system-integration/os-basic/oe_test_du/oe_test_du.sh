#!/usr/bin/bash

# Copyright (c) 2023 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wulei
# @Contact   :   wulei@uniontech.com
# @Date      :   2023.2.1
# @License   :   Mulan PSL v2
# @Desc      :   Du command test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    dir="test"
    mkdir -p ${dir}/${dir}1
    cur_lang=$(echo $LANG)
    export LANG=zh_CN.UTF-8
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cd ${dir}
    du -h | grep ./${dir}1
    CHECK_RESULT $? 0 0 "Failed to view subdirectory size"
    du -sh | grep .
    CHECK_RESULT $? 0 0 "Failed to view the current size"
    du --help| grep '用法:'
    CHECK_RESULT $? 0 0 "Failed to view the du command help manual"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf ${dir}
    export LANG=$cur_lang
    LOG_INFO "End to restore the test environment."
}
main $@
