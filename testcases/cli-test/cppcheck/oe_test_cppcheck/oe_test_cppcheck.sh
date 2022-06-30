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
# @Date      :   2020/11/09
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of cppcheck command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL cppcheck
    mkdir cppcheck1 cppcheck2 result
    cp test.cpp cppcheck1/test1.cpp
    cp file.c cppcheck1/file1.c
    cp main.c cppcheck1/main1.c
    cp test.cpp cppcheck2/test2.cpp
    cp main.c cppcheck2/main2.c
    VERSION_ID=$(grep "VERSION_ID" /etc/os-release | awk -F '\"' '{print$2}')
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cppcheck --help | grep -E "Syntax|cppcheck \[OPTIONS\] \[files or paths\]"
    CHECK_RESULT $?
    cppcheck --version | grep -i "Cppcheck"
    CHECK_RESULT $?
    cppcheck cppcheck1 | grep -E "file1.c|main1.c|test1.cpp"
    CHECK_RESULT $?
    cppcheck cppcheck1/file1.c cppcheck1/main1.c | grep -E "file1.c|main1.c"
    CHECK_RESULT $?
    cppcheck -i cppcheck2/test2.cpp cppcheck2 | grep "test2.cpp"
    CHECK_RESULT $? 1
    cppcheck file.c 2>error1 | grep "Checking file.c ..."
    CHECK_RESULT $?
    grep "error" error1
    CHECK_RESULT $?
    cppcheck --enable=all file.c 2>error2 | grep "Checking file.c ..."
    CHECK_RESULT $?
    grep -E "error|style|information" error2
    CHECK_RESULT $?
    cppcheck --enable=warning,performance cppcheck1/test1.cpp | grep "Checking cppcheck1/test1.cpp ..."
    CHECK_RESULT $?
    cppcheck --quiet cppcheck2/
    CHECK_RESULT $?
    cppcheck cppcheck2 --cppcheck-build-dir=result
    CHECK_RESULT $?
    test -f result/files.txt -a -f result/main2.a1 -a -f result/test2.a1
    CHECK_RESULT $?
    cppcheck --inconclusive cppcheck1
    CHECK_RESULT $?
    cppcheck -j 4 cppcheck1 | grep -E "Checking|checked"
    CHECK_RESULT $?
    cppcheck -I cppcheck2 cppcheck2/test2.cpp | grep "Checking cppcheck2/test2.cpp ..."
    CHECK_RESULT $?
    cppcheck --std=c99 --std=posix test.cpp
    CHECK_RESULT $?
    cppcheck --xml-version=2 file.c
    CHECK_RESULT $?
    cppcheck --xml file.c 2>err1.xml
    CHECK_RESULT $?
    grep -E "<?xml|<|>|arrayIndexOutOfBounds" err1.xml
    CHECK_RESULT $?
    cppcheck --enable=all --xml-version=2 file.c 2>err2.xml
    CHECK_RESULT $?
    grep -E "<?xml|<|>|arrayIndexOutOfBounds|unreadVariable|missingIncludeSystem" err2.xml
    CHECK_RESULT $?
    cppcheck --verbose main.c | grep -E "main.c|Defines|Includes|Platform"
    CHECK_RESULT $?
    cppcheck --template="{file}:{line},{severity},{id},{message}" file.c 2>error3 | grep "Checking file.c ..."
    CHECK_RESULT $?
    grep "error,arrayIndexOutOfBounds" error3
    CHECK_RESULT $?
    cppcheck --enable=all --template="{file}:{line},{severity},{id},{message}" file.c 2>error4 | grep "Checking file.c ..."
    CHECK_RESULT $?
    grep -E "error,arrayIndexOutOfBounds|style,unreadVariable|information,missingIncludeSystem" error4
    CHECK_RESULT $?
    cppcheck -DA file.c | grep "A=1"
    CHECK_RESULT $?
    if [ $VERSION_ID != "22.03" ]; then
        cppcheck -DA --force file.c | grep "A=1"
        CHECK_RESULT $? 1
    else
        cppcheck -DA --force file.c | grep "A=1"
        CHECK_RESULT $?
    fi
    cppcheck -DDEBUG=1-D_ucplusplus test.cpp | grep "DEBUG=1-D_ucplusplus"
    CHECK_RESULT $?
    cppcheck -UX file.c
    CHECK_RESULT $?
    cppcheck -UDEBUG test.cpp
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    roc=$(ls | grep -vE "\.sh|\.c|\.cpp")
    rm -rf $roc
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
