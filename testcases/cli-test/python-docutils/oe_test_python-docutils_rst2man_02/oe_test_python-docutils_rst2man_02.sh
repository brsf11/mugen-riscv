#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
#@Date      	:   2020-10-19
#@License   	:   Mulan PSL v2
#@Desc      	:   The command rst2man parameter coverage test of the python-docutils package
#####################################

source "${OET_PATH}"/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "python-docutils"
    cp -r ../common/error.rst ./
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2man -r 1 error.rst test1.man && test -f test1.man
    CHECK_RESULT $?
    rst2man -v error.rst test2.man && test -f test2.man
    CHECK_RESULT $?
    rst2man -q error.rst test3.man && test -f test3.man
    CHECK_RESULT $?
    rst2man --halt=1 error.rst test4.man 2>&1 | grep 'due to level-1'
    CHECK_RESULT $?
    test -f test4.man
    CHECK_RESULT $? 0 1
    rst2man --strict error.rst test5.man 2>&1 | grep 'Exiting due to level-1'
    CHECK_RESULT $?
    test -f test5.man
    CHECK_RESULT $? 0 1
    rst2man --exit-status=1 error.rst test6.man 2>&1 | grep 'INFO'
    CHECK_RESULT $? 1
    test -f test6.man
    CHECK_RESULT $?
    rst2man --debug error.rst test7_1.man 2>&1 | grep 'DEBUG'
    CHECK_RESULT $?
    rst2man --no-debug error.rst test7_2.man && test -f test7_2.man
    CHECK_RESULT $?
    rst2man --halt=1 --warnings=warning.log error.rst test8.man 2>&1 | grep 'due to level-1' && ls warning.log
    CHECK_RESULT $?
    rst2man --traceback error.rst test9_1.man && test -f test9_1.man
    CHECK_RESULT $?
    rst2man --no-traceback error.rst test9_2.man && test -f test9_2.man
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.man ./*.rst ./*.log
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
