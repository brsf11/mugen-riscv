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
#@Date      	:   2020-10-13
#@License   	:   Mulan PSL v2
#@Desc      	:   The command rst2html5 parameter coverage test of the python-docutils package
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
    rst2html5 --title=testtitle testfile.rst test1.html && grep testtitle test1.html
    CHECK_RESULT $?
    rst2html5 -g testfile.rst test2.html && grep 'href="http://docutils.sourceforge.net/' test2.html
    CHECK_RESULT $?
    rst2html5 --no-generator testfile.rst test3.html
    CHECK_RESULT $?
    grep 'href="http://docutils.sourceforge.net/' test3.html
    CHECK_RESULT $? 1
    rst2html5 -d -t testfile.rst test4.html && grep -E "Generated on: [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ UTC" test4.html
    CHECK_RESULT $?
    rst2html5 -d -t --no-datestamp testfile.rst test5.html
    CHECK_RESULT $?
    grep -E "Generated on: [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ UTC" test5.html
    CHECK_RESULT $? 1
    rst2html5 -s testfile.rst test6.html && grep 'href="testfile.rst"' test6.html
    CHECK_RESULT $?
    rst2html5 --source-url=http://testpage.org testfile.rst test7.html && grep 'http://testpage.org' test7.html
    CHECK_RESULT $?
    rst2html5 -s --no-source-link testfile.rst test8.html
    CHECK_RESULT $?
    grep 'href="testfile.rst"' test8.html
    CHECK_RESULT $? 1
    rst2html5 --toc-entry-backlinks testfile.rst test9.html && grep 'class="toc-backref" href="#id' test9.html
    CHECK_RESULT $?
    rst2html5 --toc-top-backlinks testfile.rst test10.html && grep 'class="toc-backref" href="#table-of-contents-title"' test10.html
    CHECK_RESULT $?
    rst2html5 --no-toc-backlinks testfile.rst test11.html
    CHECK_RESULT $?
    grep 'class="toc-backref" href="#id' test11.html
    CHECK_RESULT $? 1
    rst2html5 --no-footnote-backlinks testfile.rst test12_1.html
    CHECK_RESULT $?
    grep 'class="fn-backref"' test12_1.html
    CHECK_RESULT $? 1
    rst2html5 --footnote-backlinks testfile.rst test12_2.html && grep 'class="fn-backref"' test12_2.html
    CHECK_RESULT $?
    rst2html5 --strip-comments testfile.rst test13.html
    CHECK_RESULT $?
    grep '_so: is this' test13.html
    CHECK_RESULT $? 1
    rst2html5 --strip-comments --leave-comments testfile.rst test14.html && grep '_so: is this' test14.html
    CHECK_RESULT $?
    rst2html5 --strip-elements-with-class=special testfile.rst test15.html
    CHECK_RESULT $?
    grep 'class="special"' test15.html
    CHECK_RESULT $? 1
    rst2html5 --strip-class=multiple testfile.rst test16.html
    CHECK_RESULT $?
    grep multiple test16.html
    CHECK_RESULT $? 1
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.html ./*.rst
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
