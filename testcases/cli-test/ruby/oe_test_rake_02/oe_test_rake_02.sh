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
# @Date      :   2020/11/19
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of rake command
# ############################################

source "../common/common_ruby.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rubygem-rake
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rake -e "puts 'hello'" | grep "hello"
    CHECK_RESULT $?
    rake -E "puts 'hello'" | grep -E "hello|Turned off alarm"
    CHECK_RESULT $?
    rake -f rakefile | grep "Turned off alarm"
    CHECK_RESULT $?
    rake -G | grep "Turned off alarm"
    CHECK_RESULT $?
    rake -g | grep "Turned off alarm"
    CHECK_RESULT $?
    mkdir tmp
    CHECK_RESULT $?
    touch tmp/file1 tmp/file2 tmp/file3
    CHECK_RESULT $?
    rake -I tmp | grep "Turned off alarm"
    CHECK_RESULT $?
    expect <<EOF
        spawn rake root:clean_tmp -j 4
        expect "? " {send "y\r"}
        expect "? " {send "y\r"}
        expect "? " {send "y\r"}
        expect "? " {send "q\r"}
        expect eof
EOF
    [ ! -f tmp/file1 ] && [ ! -f tmp/file2 ] && [ ! -f tmp/file3 ]
    CHECK_RESULT $?
    rake -m | grep "Turned off alarm"
    CHECK_RESULT $?
    rake morning:ready_for_the_day -n
    CHECK_RESULT $?
    rake -N | grep "Turned off alarm"
    CHECK_RESULT $?
    mkdir temp && cd temp || exit 1
    CHECK_RESULT $?
    rake -N >runlog 2>&1
    CHECK_RESULT $? 1
    grep "No Rakefile found" runlog
    CHECK_RESULT $?
    cd .. || exit 1
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    delete_files
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
