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
# @Date      :   2020/11/17
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of erb command
# ############################################

source "../common/common_ruby.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ruby
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    erb --help >helpinfo 2>&1
    grep -E "erb|-" helpinfo
    CHECK_RESULT $?
    erb --version 2>&1 | grep "erb.*[0-9]"
    CHECK_RESULT $?
    erb -x example1.erb | grep "_erbout"
    CHECK_RESULT $?
    erb -x -n example1.erb | grep '\<[0-9]\>'
    CHECK_RESULT $?
    erb -x -v example1.erb | grep "_erbout"
    CHECK_RESULT $?
    erb -x -d example1.erb | grep -E "require|erbout"
    CHECK_RESULT $?
    erb -r 'prime' -T - example2.erb | grep -E "<|>"
    CHECK_RESULT $?
    erb -S 0 -x example1.erb | grep "freeze"
    CHECK_RESULT $?
    erb -E external -x example1.erb | grep -E "freeze|erbout"
    CHECK_RESULT $?
    erb -U -x example1.erb | grep "erbout"
    CHECK_RESULT $?
    erb -T - example1.erb | grep -E "<|>"
    CHECK_RESULT $?
    erb -P -x example1.erb | grep "erb-example"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    delete_files
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
