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
    rstpep2html --language=fr pep.rst test1.html && grep 'sommaire' test1.html
    CHECK_RESULT $?
    rstpep2html --record-dependencies=recordlist.log pep.rst test2.html && grep 'pep.css' recordlist.log
    CHECK_RESULT $?
    test "$(rstpep2html -V | awk '{print$3}')" == "$(rpm -qa python3-docutils | awk -F "-" '{print$3}')"
    CHECK_RESULT $?
    rstpep2html -h | grep 'Usage'
    CHECK_RESULT $?
    rstpep2html --python-home=http://www.python.org pep.rst test5.html && test -f test5.html
    CHECK_RESULT $?
    rstpep2html --pep-home=/root/ pep.rst test6.html && test -f test6.html
    CHECK_RESULT $?
    rstpep2html --pep-references pep.rst test7.html && test -f test7.html
    CHECK_RESULT $?
    rstpep2html --pep-base-url=http://www.abc.org/dev/peps/ pep.rst test8.html && test -f test8.html
    CHECK_RESULT $?
    rstpep2html --pep-file-url-template=pep-484 pep.rst test9.html && test -f test9.html
    CHECK_RESULT $?
    rstpep2html --rfc-references pep.rst test10.html && test -f test10.html
    CHECK_RESULT $?
    rstpep2html --rfc-base-url=http://www.abc.org/rfcs/ pep.rst test11.html && test -f test11.html
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
