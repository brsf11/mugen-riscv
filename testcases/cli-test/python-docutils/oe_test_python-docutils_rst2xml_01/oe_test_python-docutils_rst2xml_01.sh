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
#@Date      	:   2020-10-12
#@License   	:   Mulan PSL v2
#@Desc      	:   The command rst2xml parameter coverage test of the python-docutils package
#####################################
source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cp -r ../common/testfile.rst ./
    DNF_INSTALL "python-docutils"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2xml --title=testtitle testfile.rst test1.xml && grep testtitle test1.xml
    CHECK_RESULT $?
    rst2xml -g testfile.rst test2.xml && grep -nr 'refuri' test2.xml
    CHECK_RESULT $?
    rst2xml --no-generator testfile.rst test3.xml && grep -nr 'refuri' test3.xml
    CHECK_RESULT $? 1
    rst2xml -d -t testfile.rst test4.xml && grep -E "Generated on: [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ UTC" test4.xml
    CHECK_RESULT $?
    rst2xml -d -t --no-datestamp testfile.rst test5.xml
    CHECK_RESULT $?
    grep -E "Generated on: [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ UTC" test5.xml
    CHECK_RESULT $? 1
    rst2xml -s testfile.rst test6.xml && grep 'refuri="testfile.rst"' test6.xml
    CHECK_RESULT $?
    rst2xml --source-url=http://testpage.org testfile.rst test7.xml && grep 'http://testpage.org' test7.xml
    CHECK_RESULT $?
    rst2xml -s --no-source-link testfile.rst test8.xml
    CHECK_RESULT $?
    grep 'refuri="testfile.rst"' test8.xml
    CHECK_RESULT $? 1
    rst2xml --toc-entry-backlinks testfile.rst test9.xml && grep 'title refid="id' test9.xml
    CHECK_RESULT $?
    rst2xml --toc-top-backlinks testfile.rst test10.xml && grep 'title refid="table-of-contents-title"' test10.xml
    CHECK_RESULT $?
    rst2xml --no-toc-backlinks testfile.rst test11.xml
    CHECK_RESULT $?
    grep 'title refid=' test11.xml
    CHECK_RESULT $? 1
    rst2xml --no-footnote-backlinks testfile.rst test12_1.xml
    CHECK_RESULT $?
    rst2xml --footnote-backlinks testfile.rst test12_2.xml
    CHECK_RESULT $?
    grep "citation backrefs=" test12_2.xml
    CHECK_RESULT $?
    rst2xml --strip-comments testfile.rst test13.xml
    CHECK_RESULT $?
    grep comment test13.xml
    CHECK_RESULT $? 1
    rst2xml --strip-comments --leave-comments testfile.rst test14.xml && grep comment test14.xml
    CHECK_RESULT $?
    rst2xml --strip-elements-with-class=special testfile.rst test15.xml
    CHECK_RESULT $?
    grep special test15.xml
    CHECK_RESULT $? 1
    rst2xml --strip-class=multiple testfile.rst test16.xml
    CHECK_RESULT $?
    grep multiple test16.xml
    CHECK_RESULT $? 1
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.xml ./*.rst
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
