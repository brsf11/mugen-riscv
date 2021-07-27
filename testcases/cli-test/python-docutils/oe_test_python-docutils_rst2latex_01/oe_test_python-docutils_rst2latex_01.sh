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
    cp -r ../common/testfile_tex.rst ./testfile.rst
    touch subfig.sty
    DNF_INSTALL "python-docutils"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2latex --title=testtitle testfile.rst test1.tex
    CHECK_RESULT $?
    rst2latex -g testfile.rst test2.tex &&
        grep 'href{http://docutils.sourceforge.net/}' test2.tex
    CHECK_RESULT $?
    rst2latex --no-generator testfile.rst test3.tex
    CHECK_RESULT $?
    grep 'href{http://docutils.sourceforge.net/}' test3.tex
    CHECK_RESULT $? 0 1
    rst2latex -d -t testfile.rst test4.tex &&
        grep -E "Generated on: [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ UTC" test4.tex
    CHECK_RESULT $?
    rst2latex -d -t --no-datestamp testfile.rst test5.tex
    CHECK_RESULT $?
    grep -E "Generated on: [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ UTC" test5.tex
    CHECK_RESULT $? 0 1
    rst2latex -s testfile.rst test6.tex && grep 'href{testfile.rst}' test6.tex
    CHECK_RESULT $?
    rst2latex --source-url=http://testpage.org testfile.rst test7.tex &&
        grep 'http://testpage.org' test7.tex
    CHECK_RESULT $?
    rst2latex -s --no-source-link testfile.rst test8.tex
    CHECK_RESULT $?
    grep 'testfile.rst' test8.tex
    CHECK_RESULT $? 0 1
    rst2latex --toc-entry-backlinks testfile.rst test9.tex &&
        test -f test9.tex
    CHECK_RESULT $?
    rst2latex --toc-top-backlinks testfile.rst test10.tex &&
        test -f test10.tex
    CHECK_RESULT $?
    rst2latex --no-toc-backlinks testfile.rst test11.tex &&
        test -f test11.tex
    CHECK_RESULT $?
    rst2latex --no-footnote-backlinks testfile.rst test12_1.tex &&
        test -f test12_1.tex
    CHECK_RESULT $?
    rst2latex --footnote-backlinks testfile.rst test12_2.tex &&
        test -f test12_2.tex
    CHECK_RESULT $?
    rst2latex --strip-comments testfile.rst test13.tex
    CHECK_RESULT $?
    grep 'so: is this!' test13.tex
    CHECK_RESULT $? 0 1
    rst2latex --strip-comments --leave-comments testfile.rst test14.tex &&
        grep 'so: is this!' test14.tex
    CHECK_RESULT $?
    rst2latex --strip-elements-with-class=special testfile.rst test15.tex
    CHECK_RESULT $?
    grep special test15.tex
    CHECK_RESULT $? 0 1
    rst2latex --strip-class=multiple testfile.rst test16.tex
    CHECK_RESULT $?
    grep multiple test16.tex
    CHECK_RESULT $? 0 1
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.tex ./*.rst ./*.log ./*.sty
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
