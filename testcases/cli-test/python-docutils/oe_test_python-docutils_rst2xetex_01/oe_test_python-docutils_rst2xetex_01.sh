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
    rst2xetex --title=testtitle testfile.rst test1.tex && test -f test1.tex
    CHECK_RESULT $?
    rst2xetex -g testfile.rst test2.tex && grep 'href{http://docutils.sourceforge.net/}' test2.tex
    CHECK_RESULT $?
    rst2xetex --no-generator testfile.rst test3.tex
    CHECK_RESULT $?
    grep 'href{http://docutils.sourceforge.net/}' test3.tex
    CHECK_RESULT $? 0 1
    rst2xetex -d -t testfile.rst test4.tex && grep -E "Generated on: [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ UTC" test4.tex
    CHECK_RESULT $?
    rst2xetex -d -t --no-datestamp testfile.rst test5.tex
    CHECK_RESULT $?
    grep -E "Generated on: [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ UTC" test5.tex
    CHECK_RESULT $? 0 1
    rst2xetex -s testfile.rst test6.tex && grep 'href{testfile.rst}' test6.tex
    CHECK_RESULT $?
    rst2xetex --source-url=http://testpage.org testfile.rst test7.tex && grep 'http://testpage.org' test7.tex
    CHECK_RESULT $?
    rst2xetex -s --no-source-link testfile.rst test8.tex
    CHECK_RESULT $?
    grep 'testfile.rst' test8.tex
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
