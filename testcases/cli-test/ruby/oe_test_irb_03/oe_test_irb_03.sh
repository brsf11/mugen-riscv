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
    VERSION_ID=$(grep "VERSION_ID" /etc/os-release | awk -F '\"' '{print$2}')
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    irb --sample-book-mode ../common/hello.rb | grep -E ">>|Hello World"
    CHECK_RESULT $?
    irb --noprompt ../common/hello.rb | grep -E "Hello World|nil"
    CHECK_RESULT $?
    irb --single-irb ../common/hello.rb | grep -i "hello"
    CHECK_RESULT $?
    irb --tracer ../common/hello.rb | grep "hello.rb:3"
    CHECK_RESULT $?
    irb --back-trace-limit 2 ../common/hello.rb | grep "Hello World"
    CHECK_RESULT $?
    if [ $VERSION_ID != "22.03" ]; then
       irb --irb_debug 3 ../common/hello.rb | grep -E "Tree|preproc|postproc"
       CHECK_RESULT $?
    fi
    irb --verbose ../common/hello.rb | grep -E "Switch to inspect mode.|hello|main"
    CHECK_RESULT $?
    irb --noverbose ../common/hello.rb | grep -E "Switch to inspect mode.|hello|main"
    CHECK_RESULT $? 1
    irb -- ../common/hello.rb | grep "Hello World"
    CHECK_RESULT $?
    expect <<EOF
        log_file result
        spawn irb
        expect "irb(main):001:0>" {send "1+5\r"}
        expect " " {send "puts 'Hello World!'\r"}
        expect " " {send "quit\r"}
        expect eof
EOF
    grep -E "6|Hello World!" result
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
