#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   doraemon2020
#@Contact   	:   xcl_job@163.com
#@Date      	:   2020-10-12
#@License   	:   Mulan PSL v2
#@Desc      	:   The command rst2pseudoxml parameter coverage test of the python-docutils package
#####################################
source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cp -r ../common/error.rst ./
    DNF_INSTALL "python-docutils"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2pseudoxml -r 1 error.rst test1.xml
    CHECK_RESULT $?
    rst2pseudoxml -v error.rst test2.xml
    CHECK_RESULT $?
    rst2pseudoxml -q error.rst test3.xml
    CHECK_RESULT $?
    rst2pseudoxml --halt=1 error.rst test4.xml 2>&1 | grep 'due to level-1'
    CHECK_RESULT $?
    test -f test4.xml
    CHECK_RESULT $? 0 1
    rst2pseudoxml --strict error.rst test5.xml 2>&1 | grep 'Exiting due to level-1'
    CHECK_RESULT $?
    test -f test5.xml
    CHECK_RESULT $? 0 1
    rst2pseudoxml --exit-status=1 error.rst test6.xml 2>&1 | grep 'INFO'
    CHECK_RESULT $? 1
    test -f test6.xml
    CHECK_RESULT $?
    rst2pseudoxml --debug error.rst test7.xml 2>&1 | grep 'DEBUG'
    CHECK_RESULT $?
    rst2pseudoxml --no-debug error.rst test7.xml
    CHECK_RESULT $?
    rst2pseudoxml --halt=1 --warnings=warning.log error.rst test8.xml 2>&1 | grep 'due to level-1' && ls warning.log
    CHECK_RESULT $?
    rst2pseudoxml --traceback error.rst test9_1.xml && test -f test9_1.xml
    CHECK_RESULT $?
    rst2pseudoxml --no-traceback error.rst test9_2.xml && test -f test9_2.xml
    CHECK_RESULT $?
    test "$(rst2pseudoxml -V | awk '{print$3}')" == "$(rpm -qa python3-docutils | awk -F "-" '{print$3}')"
    CHECK_RESULT $?
    rst2pseudoxml -h | grep 'Usage'
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.xml ./*.rst ./*.log
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
