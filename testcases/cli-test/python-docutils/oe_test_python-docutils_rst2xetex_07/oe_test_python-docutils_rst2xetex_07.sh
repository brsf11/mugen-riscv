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
    rst2xetex --pep-references testfile.rst test1.tex && test -f test1.tex
    CHECK_RESULT $?
    rst2xetex --pep-base-url=http://www.abc.org/dev/peps/ testfile.rst test2.tex && test -f test2.tex
    CHECK_RESULT $?
    rst2xetex --pep-file-url-template=pep-484 testfile.rst test3.tex && test -f test3.tex
    CHECK_RESULT $?
    rst2xetex --rfc-references testfile.rst test4.tex && test -f test4.tex
    CHECK_RESULT $?
    rst2xetex --rfc-base-url=http://www.abc.org/rfcs/ testfile.rst test5.tex && test -f test5.tex
    CHECK_RESULT $?
    rst2xetex --tab-width=4 testfile.rst test6.tex && test -f test6.tex
    CHECK_RESULT $?
    rst2xetex --trim-footnote-reference-space testfile.rst test7.tex && test -f test7.tex
    CHECK_RESULT $?
    rst2xetex --leave-footnote-reference-space testfile.rst test8.tex && test -f test8.tex
    CHECK_RESULT $?
    rst2xetex --no-file-insertion testfile.rst test9.tex && test -f test9.tex
    CHECK_RESULT $?
    rst2xetex --file-insertion-enabled testfile.rst test10.tex && test -f test10.tex
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
