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
# @Date      :   2020/10/20
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of php-dbg command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL php-dbg
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
        spawn phpdbg --help
        expect "" {send "q\r"}
        expect eof
EOF
    phpdbg --version | grep "phpdbg"
    CHECK_RESULT $?
    expect <<EOF
        spawn phpdbg
        expect "prompt> " {send "list\r"}
        expect "prompt> " {send "info\r"}
        expect "prompt> " {send "print\r"}
        expect "prompt> " {send "frame\r"}
        expect "prompt> " {send "generator\r"}
        expect "prompt> " {send "back\r"}
        expect "prompt> " {send "help\r"}
        expect "" {send "q\r"}
        expect "prompt> " {send "exec\r"}
        expect "prompt> " {send "stdin\r"}
        expect "prompt> " {send "run\r"}
        expect "prompt> " {send "step\r"}
        expect "prompt> " {send "continue\r"}
        expect "prompt> " {send "until\r"}
        expect "prompt> " {send "next\r"}
        expect "prompt> " {send "finish\r"}
        expect "prompt> " {send "leave\r"}
        expect "prompt> " {send "break\r"}
        expect "prompt> " {send "watch\r"}
        expect "prompt> " {send "clear\r"}
        expect "prompt> " {send "clean\r"}
        expect "prompt> " {send "set\r"}
        expect "prompt> " {send "source\r"}
        expect "prompt> " {send "register\r"}
        expect "prompt> " {send "sh\r"}
        expect "prompt> " {send "ev\r"}
        expect "prompt> " {send "quit\r"}
        expect eof
EOF
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
