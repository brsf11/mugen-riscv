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
    cp -r ../common/template.tex ./
    touch subfig.sty
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2xetex --docutils-footnotes testfile.rst test3.tex && grep 'footnotetext' test3.tex
    CHECK_RESULT $?
    rst2xetex --footnote-references=brackets testfile.rst test4.tex && grep 'DUfootnotetext{id4}{id2}{{\[}1{\]}}' test4.tex
    CHECK_RESULT $?
    rst2xetex --use-latex-citations testfile.rst test5.tex && grep 'cite{CIT1}' test5.tex
    CHECK_RESULT $?
    rst2xetex --figure-citations testfile.rst test6.tex && grep 'hyperlink{cit1}' test6.tex
    CHECK_RESULT $?
    rst2xetex --attribution=parentheses testfile.rst test7.tex && grep 'raggedleft (Buckaroo Banzai)' test7.tex
    CHECK_RESULT $?
    rst2xetex --stylesheet=subfig.sty testfile.rst test8.tex && grep 'usepackage{subfig}' test8.tex
    CHECK_RESULT $?
    rst2xetex --stylesheet-path=subfig.sty testfile.rst test9.tex && grep 'usepackage{subfig}' test9.tex
    CHECK_RESULT $?
    rst2xetex --link-stylesheet --stylesheet-dirs=/root/ testfile.rst test10.tex
    CHECK_RESULT $?
    rst2xetex --embed-stylesheet testfile.rst test11.tex
    CHECK_RESULT $?
    rst2xetex --latex-preamble=Helvetica testfile.rst test12.tex && grep 'Helvetica' test12.tex
    CHECK_RESULT $?
    rst2xetex --template=template.tex testfile.rst test13.tex && grep 'author{tester}' test13.tex
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
