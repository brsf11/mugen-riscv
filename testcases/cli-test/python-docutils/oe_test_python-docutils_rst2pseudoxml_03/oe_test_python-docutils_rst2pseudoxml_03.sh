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
#@Date      	:   2020-10-12
#@License   	:   Mulan PSL v2
#@Desc      	:   The command rst2pseudoxml parameter coverage test of the python-docutils package
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "python-docutils"
    cp -r ../common/testfile.rst ./
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2pseudoxml --language=en-GB testfile.rst test1.xml && test -f test1.xml
    CHECK_RESULT $?
    rst2pseudoxml --record-dependencies=recordlist.log testfile.rst test2.xml && test -f test2.xml
    CHECK_RESULT $?
    test "$(rst2pseudoxml -V | awk '{print$3}')" == "$(rpm -qa python3-docutils | awk -F "-" '{print$3}')"
    CHECK_RESULT $?
    rst2pseudoxml -h | grep 'Usage'
    CHECK_RESULT $?
    rst2pseudoxml --no-doc-title testfile.rst test3.xml && test -f test3.xml
    CHECK_RESULT $?
    rst2pseudoxml --no-doc-info testfile.rst test4.xml && test -f test4.xml
    CHECK_RESULT $?
    rst2pseudoxml --section-subtitles testfile.rst test5.xml && test -f test4.xml
    CHECK_RESULT $?
    rst2pseudoxml --no-section-subtitles testfile.rst test6.xml && test -f test6.xml
    CHECK_RESULT $?
    rst2pseudoxml --pep-references testfile.rst test7.xml && test -f test7.xml
    CHECK_RESULT $?
    rst2pseudoxml --pep-base-url=http://www.abc.org/dev/peps/ testfile.rst test8.xml && test -f test8.xml
    CHECK_RESULT $?
    rst2pseudoxml --pep-file-url-template=pep-484 testfile.rst test9.xml && test -f test9.xml
    CHECK_RESULT $?
    rst2pseudoxml --rfc-references testfile.rst test10.xml && test -f test10.xml
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.xml ./*.rst
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
