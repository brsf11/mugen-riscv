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
#@Date      	:   2020-10-16
#@License   	:   Mulan PSL v2
#@Desc      	:   The command rst2latex parameter coverage test of the python-docutils package
#####################################
source "${OET_PATH}"/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cp -r ../common/error.rst ./
    touch subfig.sty
    DNF_INSTALL "python-docutils"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2latex -r 1 error.rst test1.tex
    [ -e test1.tex ]
    CHECK_RESULT $?
    rst2latex -v error.rst test2.tex
    [ -e test2.tex ]
    CHECK_RESULT $?
    rst2latex -q error.rst test3.tex
    [ -e test3.tex ]
    CHECK_RESULT $?
    rst2latex --halt=1 error.rst test4.tex 2>&1 | grep 'due to level-1'
    CHECK_RESULT $?
    test -f test4.html
    CHECK_RESULT $? 0 1
    rst2latex --strict error.rst test5.tex 2>&1 | grep 'Exiting due to level-1'
    CHECK_RESULT $?
    test -f test5.html
    CHECK_RESULT $? 0 1
    rst2latex --exit-status=1 error.rst test6.tex 2>&1 | grep 'INFO'
    CHECK_RESULT $? 1
    test -f test6.html
    CHECK_RESULT $? 0 1
    rst2latex --debug error.rst test7.tex 2>&1 | grep 'DEBUG'
    CHECK_RESULT $?
    rst2latex --no-debug error.rst test7.tex
    CHECK_RESULT $?
    rst2latex --halt=1 --warnings=warning.log error.rst test8.tex 2>&1 |
        grep 'due to level-1' && ls warning.log
    CHECK_RESULT $?
    rst2latex --traceback error.rst test9_1.tex &&
        test -f test9_1.tex
    CHECK_RESULT $?
    rst2latex --no-traceback error.rst test9_2.tex &&
        test -f test9_2.tex
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.tex ./*.rst ./*.log ./*.sty
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
