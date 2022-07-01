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
#@Desc      	:   The command rst2man parameter coverage test of the python-docutils package
#####################################

source "${OET_PATH}"/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "python-docutils"
    cp -r ../common/testfile.rst ./
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2man --language=en-GB testfile.rst test1.man && test -f test1.man
    CHECK_RESULT $?
    rst2man --record-dependencies=recordlist.log testfile.rst test2.man
    CHECK_RESULT $?
    test "$(rst2man -V | awk '{print$3}')" == "$(rpm -qa python3-docutils | awk -F "-" '{print$3}')"
    CHECK_RESULT $?
    rst2man -h | grep 'Usage'
    CHECK_RESULT $?
    rst2man --no-doc-title testfile.rst test5.man && test -f test5.man
    CHECK_RESULT $?
    rst2man --no-doc-info testfile.rst test6.man && test -f test6.man
    CHECK_RESULT $?
    rst2man --section-subtitles testfile.rst test7.man && test -f test7.man
    CHECK_RESULT $?
    rst2man --no-section-subtitles testfile.rst test8.man && test -f test8.man
    CHECK_RESULT $?
    rst2man --pep-references testfile.rst test9.man && test -f test9.man
    CHECK_RESULT $?
    rst2man --pep-base-url=http://www.abc.org/dev/peps/ testfile.rst test10.man && test -f test10.man
    CHECK_RESULT $?
    rst2man --pep-file-url-template=pep-484 testfile.rst test11.man && test -f test11.man
    CHECK_RESULT $?
    rst2man --rfc-references testfile.rst test12.man && test -f test12.man
    CHECK_RESULT $?
    rst2man --rfc-base-url=http://www.abc.org/rfcs/ testfile.rst test13.man && test -f test13.man
    CHECK_RESULT $?
    rst2man --tab-width=4 testfile.rst test14.man && test -f test14.man
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.man ./*.rst ./*.log
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
