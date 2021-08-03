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
# @Date      :   2020/11/18
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of irb command
# ############################################

source "../common/common_ruby.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ruby-irb
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mkdir hello
    CHECK_RESULT $?
    irb --version | grep "irb.*[0-9]"
    CHECK_RESULT $?
    irb --help | grep -E "Usage:|-"
    CHECK_RESULT $?
    irb -d ../common/hello.rb | grep "hello.rb"
    CHECK_RESULT $?
    irb -f -d ../common/hello.rb | grep "hello"
    CHECK_RESULT $?
    irb ../common/test.rb | grep "uninitialized constant Prime"
    CHECK_RESULT $?
    irb -r 'prime' ../common/test.rb | grep -E "2, 3, 5, 7|Hello World!"
    CHECK_RESULT $?
    irb -I hello ../common/hello.rb | grep "Hello World!"
    CHECK_RESULT $?
    irb -U ../common/hello.rb | grep "puts"
    CHECK_RESULT $?
    irb -E internal ../common/hello.rb | grep "Hello World"
    CHECK_RESULT $?
    irb -w -r 'prime' ../common/test.rb | grep "Prime"
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
