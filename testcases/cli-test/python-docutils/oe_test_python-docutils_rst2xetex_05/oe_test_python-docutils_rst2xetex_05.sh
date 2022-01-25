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
#@Desc      	:   The command rst2xetex parameter coverage test of the python-docutils package
#####################################

source "${OET_PATH}"/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "python-docutils"
    cp -r ../common/testfile_tex.rst ./testfile.rst
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2xetex --use-latex-toc testfile.rst test1.tex && test -f test1.tex
    CHECK_RESULT $?
    rst2xetex --use-docutils-toc testfile.rst test2.tex && grep 'DUtitle\[contents\]' test2.tex
    CHECK_RESULT $?
    rst2xetex --use-part-section testfile.rst test3.tex && grep 'part{Title 1' test3.tex
    CHECK_RESULT $?
    rst2xetex --use-docutils-docinfo testfile.rst test4.tex && test -f test1.tex
    CHECK_RESULT $?
    rst2xetex --use-latex-docinfo testfile.rst test5.tex && grep 'author{TESTER}' test5.tex
    CHECK_RESULT $?
    rst2xetex --topic-abstract testfile.rst test6.tex && test -f test6.tex
    CHECK_RESULT $?
    rst2xetex --use-latex-abstract testfile.rst test7.tex && test -f test7.tex
    CHECK_RESULT $?
    rst2xetex --hyperlink-color=red testfile.rst test8.tex && grep 'urlcolor=red' test8.tex
    CHECK_RESULT $?
    rst2xetex --hyperref-options=hyperref testfile.rst test9.tex && grep -E 'usepackage\[.*,hyperref\]{hyperref}' test9.tex
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
