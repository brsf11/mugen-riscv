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
    cp -r ../common/pep.rst ./
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rstpep2html --option-limit=7 pep.rst test1.html && test -f test1.html
    CHECK_RESULT $?
    rstpep2html --footnote-references=superscript pep.rst test2.html && grep '<sup>1' test2.html
    CHECK_RESULT $?
    rstpep2html --attribution=none pep.rst test3.html && grep '<p class="attribution">Buckaroo Banzai' test3.html
    CHECK_RESULT $?
    rstpep2html --compact-lists pep.rst test4.html && test -f test4.html
    CHECK_RESULT $?
    rstpep2html --no-compact-lists pep.rst test5.html && grep '<p class="first">' test5.html
    CHECK_RESULT $?
    rstpep2html --compact-field-lists pep.rst test6.html && test -f test6.html
    CHECK_RESULT $?
    rstpep2html --compact-field-lists pep.rst test7.html && test -f test7.html
    CHECK_RESULT $?
    rstpep2html --table-style=collapse pep.rst test8.html && grep 'class="docutils collapse"' test8.html
    CHECK_RESULT $?
    rstpep2html --math-output=MathML pep.rst test9.html && test -f test9.html
    CHECK_RESULT $?
    rstpep2html --no-xml-declaration pep.rst test10.html && test -f test10.html
    CHECK_RESULT $?
    rstpep2html --cloak-email-addresses pep.rst test11.html && test -f test11.html
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
