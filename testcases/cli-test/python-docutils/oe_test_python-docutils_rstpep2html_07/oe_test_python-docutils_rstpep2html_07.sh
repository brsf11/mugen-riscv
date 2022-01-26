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
    rstpep2html --toc-top-backlinks pep.rst test1.html && grep 'class="toc-backref" href="#contents"' test1.html
    CHECK_RESULT $?
    rstpep2html --no-toc-backlinks pep.rst test2.html
    CHECK_RESULT $?
    grep 'class="toc-backref" href="#id12"' test2.html
    CHECK_RESULT $? 0 1
    rstpep2html --no-footnote-backlinks pep.rst test3.html
    CHECK_RESULT $?
    grep 'class="fn-backref"' test3.html
    CHECK_RESULT $? 0 1
    rstpep2html --footnote-backlinks pep.rst test4.html && grep 'class="fn-backref"' test4.html
    CHECK_RESULT $?
    rstpep2html --strip-comments pep.rst test5.html
    CHECK_RESULT $?
    grep '_so: is this' test5.html
    CHECK_RESULT $? 0 1
    rstpep2html --strip-comments --leave-comments pep.rst test6.html && grep '_so: is this' test6.html
    CHECK_RESULT $?
    rstpep2html --strip-elements-with-class=special pep.rst test7.html
    CHECK_RESULT $?
    grep special test7.html
    CHECK_RESULT $? 0 1
    rstpep2html --strip-class=multiple pep.rst test8.html
    CHECK_RESULT $?
    grep multiple test8.html
    CHECK_RESULT $? 0 1
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.html ./*.rst ./*.log
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
