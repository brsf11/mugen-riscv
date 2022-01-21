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
    cp -r ../common/testfile.rst ./
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2man --title=testtitle testfile.rst test1.man && test -f test1.man
    CHECK_RESULT $?
    rst2man -g testfile.rst test2.man && test -f test2.man
    CHECK_RESULT $?
    rst2man --no-generator testfile.rst test3.man && test -f test2.man
    CHECK_RESULT $?
    rst2man -d -t testfile.rst test4.man && grep -E "Generated on: [0-9]+\\\-[0-9]+\\\-[0-9]+ [0-9]+:[0-9]+ UTC" test4.man
    CHECK_RESULT $?
    rst2man -d -t --no-datestamp testfile.rst test5.man
    CHECK_RESULT $?
    grep -E "Generated on: [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ UTC" test5.man
    CHECK_RESULT $? 0 1
    rst2man -s testfile.rst test6.man && grep 'View document source' test6.man
    CHECK_RESULT $?
    rst2man --source-url=http://testpage.org testfile.rst test7.man && grep 'View document source' test7.man
    CHECK_RESULT $?
    rst2man -s --no-source-link testfile.rst test8.man
    CHECK_RESULT $?
    grep 'View document source' test8.man
    CHECK_RESULT $? 0 1
    rst2man --toc-entry-backlinks testfile.rst test9.man && test -f test9.man
    CHECK_RESULT $?
    rst2man --toc-top-backlinks testfile.rst test10.man && test -f test10.man
    CHECK_RESULT $?
    rst2man --no-toc-backlinks testfile.rst test11.man && test -f test11.man
    CHECK_RESULT $?
    rst2man --no-footnote-backlinks testfile.rst test12_1.man && test -f test12_1.man
    CHECK_RESULT $?
    rst2man --footnote-backlinks testfile.rst test12_2.man && test -f test12_2.man
    CHECK_RESULT $?
    rst2man --strip-comments testfile.rst test13.man
    CHECK_RESULT $?
    grep '_so: is this' test13.man
    CHECK_RESULT $? 0 1
    rst2man --strip-comments --leave-comments testfile.rst test14.man && grep '_so: is this' test14.man
    CHECK_RESULT $?
    rst2man --strip-elements-with-class=special testfile.rst test15.man
    CHECK_RESULT $?
    grep special test15.man
    CHECK_RESULT $? 0 1
    rst2man --strip-class=multiple testfile.rst test16.man
    CHECK_RESULT $?
    grep multiple test16.man
    CHECK_RESULT $? 0 1
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.man ./*.rst ./*.log
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
