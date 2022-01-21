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
#@Desc      	:   The command rst2odt parameter coverage test of the python-docutils package
#####################################

source "${OET_PATH}"/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "python-docutils"
    cp -r ../common/testfile_odt.rst ./testfile.rst
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2odt --title=testtitle testfile.rst test1.odt && test -f test1.odt
    CHECK_RESULT $?
    rst2odt -g testfile.rst test2.odt && test -f test2.odt
    CHECK_RESULT $?
    rst2odt --no-generator testfile.rst test3.odt && test -f test3.odt
    CHECK_RESULT $?
    rst2odt -d -t testfile.rst test4.odt && test -f test4.odt
    CHECK_RESULT $?
    rst2odt -d -t --no-datestamp testfile.rst test5.odt && test -f test5.odt
    CHECK_RESULT $?
    rst2odt -s testfile.rst test6.odt && test -f test6.odt
    CHECK_RESULT $?
    rst2odt --source-url=http://testpage.org testfile.rst test7.odt && test -f test7.odt
    CHECK_RESULT $?
    rst2odt -s --no-source-link testfile.rst test8.odt && test -f test8.odt
    CHECK_RESULT $?
    rst2odt --toc-entry-backlinks testfile.rst test9.odt && test -f test9.odt
    CHECK_RESULT $?
    rst2odt --toc-top-backlinks testfile.rst test10.odt && test -f test10.odt
    CHECK_RESULT $?
    rst2odt --no-toc-backlinks testfile.rst test11.odt && test -f test11.odt
    CHECK_RESULT $?
    rst2odt --no-footnote-backlinks testfile.rst test12_1.odt && test -f test12_1.odt
    CHECK_RESULT $?
    rst2odt --footnote-backlinks testfile.rst test12_2.odt && test -f test12_2.odt
    CHECK_RESULT $?
    rst2odt --strip-comments testfile.rst test13.odt && test -f test13.odt
    CHECK_RESULT $?
    rst2odt --strip-comments --leave-comments testfile.rst test14.odt && test -f test14.odt
    CHECK_RESULT $?
    rst2odt --strip-elements-with-class=special testfile.rst test15.odt && test -f test15.odt
    CHECK_RESULT $?
    rst2odt --strip-class=multiple testfile.rst test16.odt && test -f test16.odt
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.odt ./*.rst ./*.log
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
