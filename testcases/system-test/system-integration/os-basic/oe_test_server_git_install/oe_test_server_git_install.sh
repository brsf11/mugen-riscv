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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   24.27
# @License   :   Mulan PSL v2
# @Desc      :   Use for Git installation
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL git
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    git config --global user.name "test"
    CHECK_RESULT $?
    git config --global user.email "root@linuxprobe.com"
    CHECK_RESULT $?
    git config --global core.editor vim
    CHECK_RESULT $?
    count_git=$(git config --list | grep -icE 'test|root@linuxprobe.com|vim')
    test "$count_git" -eq 3
    CHECK_RESULT $?
    mkdir test_openEuler
    cd test_openEuler || exit 1
    git init
    echo "init" >my.txt
    git add my.txt
    CHECK_RESULT $?
    git status | grep "new file" | grep my.txt
    CHECK_RESULT $?
    git commit -m "add the redme file"
    CHECK_RESULT $?
    git status | grep "nothing to commit"
    CHECK_RESULT $?
    git log | grep "add the redme file"
    CHECK_RESULT $?
    echo "hello world!" >my.txt
    git add my.txt
    CHECK_RESULT $?
    git status | grep "modified" | grep my.txt
    CHECK_RESULT $?
    git commit -m "added a line of words"
    CHECK_RESULT $?
    git status | grep "nothing to commit"
    CHECK_RESULT $?
    git log | grep "added a line of words"
    CHECK_RESULT $(git log | grep -c commit) 2
    cd - || exit 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test_openEuler
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main $@
