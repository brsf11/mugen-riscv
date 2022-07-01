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
    rst2xml --record-dependencies=recordlist.log testfile.rst test1.xml
    CHECK_RESULT $?
    test "$(rst2xml -V| awk '{print$3}')" == "$(rpm -qa python3-docutils | awk -F "-" '{print$3}')"
    CHECK_RESULT $?
    rst2xml -h | grep 'Usage'
    CHECK_RESULT $?
    rst2xml --no-doc-title testfile.rst test4.xml && test -f test4.xml
    CHECK_RESULT $?
    rst2xml --no-doc-info testfile.rst test5.xml && test -f test5.xml
    CHECK_RESULT $?
    rst2xml --section-subtitles testfile.rst test6.xml && test -f test6.xml
    CHECK_RESULT $?
    rst2xml --no-section-subtitles testfile.rst test7.xml && test -f test7.xml
    CHECK_RESULT $?
    rst2xml --no-xml-declaration testfile.rst test8.xml
    CHECK_RESULT $?
    grep '<?xml version="1.0" encoding="utf-8"?>' test8.xml
    CHECK_RESULT $? 1
    rst2xml --no-doctype testfile.rst test9.xml
    CHECK_RESULT $?
    grep '!DOCTYPE document PUBLIC' test9.xml
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
