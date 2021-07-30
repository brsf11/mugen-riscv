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
    cp -r ../common/template.tex ./
    touch subfig.sty
    DNF_INSTALL "python-docutils"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2latex --documentclass=ctexart testfile.rst test1.tex &&
        grep 'ctexart' test1.tex
    CHECK_RESULT $?
    rst2latex --documentoptions=UTF8 testfile.rst test2_1.tex &&
        grep 'UTF8' test2_1.tex
    CHECK_RESULT $?
    rst2latex --documentoptions=a4paper,UTF8 testfile.rst test2_2.tex &&
        grep 'a4paper,UTF8' test2_2.tex
    CHECK_RESULT $?
    rst2latex --docutils-footnotes testfile.rst test3.tex &&
        grep 'footnotetext' test3.tex
    CHECK_RESULT $?
    rst2latex --footnote-references=brackets testfile.rst test4.tex &&
        grep 'DUfootnotetext{id4}{id2}{{\[}1{\]}}' test4.tex
    CHECK_RESULT $?
    rst2latex --use-latex-citations testfile.rst test5.tex &&
        grep 'cite{CIT1}' test5.tex
    CHECK_RESULT $?
    rst2latex --figure-citations testfile.rst test6.tex &&
        grep 'hyperlink{cit1}' test6.tex
    CHECK_RESULT $?
    rst2latex --attribution=parentheses testfile.rst test7.tex &&
        grep 'raggedleft (Buckaroo Banzai)' test7.tex
    CHECK_RESULT $?
    rst2latex --stylesheet=subfig.sty testfile.rst test8.tex &&
        grep 'usepackage{subfig}' test8.tex
    CHECK_RESULT $?
    rst2latex --stylesheet-path=subfig.sty testfile.rst test9.tex &&
        grep 'usepackage{subfig}' test9.tex
    CHECK_RESULT $?
    rst2latex --language=fr testfile.rst test10.tex && grep 'french' test10.tex
    CHECK_RESULT $?
    rst2latex --record-dependencies=recordlist.log testfile.rst test11.tex
    CHECK_RESULT $?
    rst2latex --latex-preamble=Helvetica testfile.rst test12.tex &&
        grep 'Helvetica' test12.tex
    CHECK_RESULT $?
    rst2latex --template=template.tex testfile.rst test13.tex &&
        grep 'author{tester}' test13.tex
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
