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
    rstpep2html --title=testtitle pep.rst test1.html && test -f test1.html
    CHECK_RESULT $?
    rstpep2html -g pep.rst test2.html && grep 'href="http://docutils.sourceforge.net/' test2.html
    CHECK_RESULT $?
    rstpep2html --no-generator pep.rst test3.html
    CHECK_RESULT $?
    grep 'href="http://docutils.sourceforge.net/' test3.html
    CHECK_RESULT $? 0 1
    rstpep2html -d -t pep.rst test4.html && grep -E "Generated on: [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ UTC" test4.html
    CHECK_RESULT $?
    rstpep2html -d -t --no-datestamp pep.rst test5.html
    CHECK_RESULT $?
    grep -E "Generated on: [0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ UTC" test5.html
    CHECK_RESULT $? 0 1
    rstpep2html -s pep.rst test6.html && grep 'href="pep.rst"' test6.html
    CHECK_RESULT $?
    rstpep2html --source-url=http://testpage.org pep.rst test7.html && grep 'http://testpage.org' test7.html
    CHECK_RESULT $?
    rstpep2html -s --no-source-link pep.rst test8.html
    CHECK_RESULT $?
    grep 'href="pep.rst"' test8.html
    CHECK_RESULT $? 0 1
    rstpep2html --toc-entry-backlinks pep.rst test9.html && grep 'class="toc-backref" href="#id12"' test9.html
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
