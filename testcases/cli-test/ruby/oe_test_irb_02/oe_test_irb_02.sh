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
    irb -W2 -r 'prime' ../common/test.rb | grep -E "Prime|2, 3, 5, 7"
    CHECK_RESULT $?
    irb --context-mode 2 ../common/hello.rb | grep "Hello World"
    CHECK_RESULT $?
    irb --echo ../common/hello.rb | grep "nil"
    CHECK_RESULT $?
    irb --noecho ../common/hello.rb | grep "nil"
    CHECK_RESULT $? 1
    irb --noinspect ../common/hello.rb | grep "=> nil"
    CHECK_RESULT $? 1
    irb --readline ../common/hello.rb | grep -E "=> nil|Hello World"
    CHECK_RESULT $?
    irb --noreadline ../common/hello.rb | grep "Hello World"
    CHECK_RESULT $?
    irb --prompt 'default' ../common/hello.rb | grep -E "hello.rb\(main\)|=> nil|Hello World!"
    CHECK_RESULT $?
    irb --prompt 'simple' ../common/hello.rb | grep "hello.rb\(main\)"
    CHECK_RESULT $? 1
    irb --prompt 'xmp' ../common/hello.rb | grep -E "==>nil|Hello World"
    CHECK_RESULT $?
    irb --prompt 'inf-ruby' ../common/hello.rb | grep -E "Hello World|nil|hello"
    CHECK_RESULT $?
    irb --inf-ruby-mode ../common/hello.rb | grep -E "hello|main|Hello World"
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
