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
    cp -r ../common/template_html.txt ./
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rstpep2html --template=template_html.txt pep.rst test1.html
    CHECK_RESULT $?
    grep '<table class="docinfo"' test1.html
    CHECK_RESULT $? 0 1
    cp -r /usr/lib/python3.*/site-packages/docutils/writers/html4css1/html4css1.css ./test.css
    rstpep2html --stylesheet=test.css pep.rst test2.html && test -f test2.html
    CHECK_RESULT $?
    rstpep2html --stylesheet-path=test.css pep.rst test3.html && test -f test3.html
    CHECK_RESULT $?
    rstpep2html --embed-stylesheet pep.rst test4.html && test -f test4.html
    CHECK_RESULT $?
    rstpep2html --link-stylesheet pep.rst test5.html && test -f test5.html
    CHECK_RESULT $?
    cp -rf /usr/lib/python3.*/site-packages/docutils/writers/html4css1/html4css1.css /root/
    rstpep2html --stylesheet-dirs=/root/ pep.rst test6.html && test -f test6.html
    CHECK_RESULT $?
    rstpep2html --initial-header-level=2 pep.rst test7.html
    CHECK_RESULT $?
    grep '<h1>' test7.html
    CHECK_RESULT $? 0 1
    rstpep2html --field-name-limit=7 pep.rst test8.html && test -f test8.html
    CHECK_RESULT $?
    rstpep2html --option-limit=7 pep.rst test9.html && test -f test9.html
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.html ./*.rst ./*.log ./*.txt ./*.css
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
