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
#@Desc      	:   The command rstpep2html parameter coverage test of the python-docutils package
#####################################

source "${OET_PATH}"/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "python-docutils"
    cp -r ../common/pep_error.rst ./
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rstpep2html -r 1 pep_error.rst test1.html && test -f test1.html
    CHECK_RESULT $?
    rstpep2html -v pep_error.rst test2.html && test -f test2.html
    CHECK_RESULT $?
    rstpep2html -q pep_error.rst test3.html && test -f test3.html
    CHECK_RESULT $?
    rstpep2html --halt=2 pep_error.rst test4.html 2>&1 | grep 'due to level-2'
    CHECK_RESULT $?
    test -f test4.html
    CHECK_RESULT $? 0 1
    rstpep2html --strict pep_error.rst test5.html 2>&1 | grep 'Exiting due to level-2'
    CHECK_RESULT $?
    test -f test5.html
    CHECK_RESULT $? 0 1
    rstpep2html --exit-status=1 pep_error.rst test6.html 2>&1 | grep 'INFO'
    CHECK_RESULT $? 1
    test -f test6.html
    CHECK_RESULT $?
    rstpep2html --debug pep_error.rst test7_1.html 2>&1 | grep 'DEBUG'
    CHECK_RESULT $?
    rstpep2html --no-debug pep_error.rst test7_2.html && test -f test7_2.html
    CHECK_RESULT $?
    rstpep2html --halt=2 --warnings=warning.log pep_error.rst test8.html 2>&1 | grep 'due to level-2' && test -f warning.log
    CHECK_RESULT $?
    rstpep2html --traceback pep_error.rst test9.html && test -f test9.html
    CHECK_RESULT $?
    rstpep2html --no-traceback pep_error.rst test10.html && test -f test10.html
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.html ./*.rst ./*.log
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
