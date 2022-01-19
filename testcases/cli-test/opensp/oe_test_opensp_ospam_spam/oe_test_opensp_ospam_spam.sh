#!/usr/bin/bash

# Copyright (c) 2020. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
#@Date      	:   2020-12-15
#@License   	:   Mulan PSL v2
#@Desc      	:   command test-spam
#####################################

source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "opensp"
    cp -r ../common/normal.sgml ./normal.sgml
    cp -r normal.sgml normal2.sgml
    printf "DOCUMENT normal.sgml\nDOCUMENT normal2.sgml" >catalogs
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ospam -b utf-8 normal.sgml | grep 'Hello'
    CHECK_RESULT $?
    ospam -f error_info.log normal.sgml && test -f error_info.log
    CHECK_RESULT $?
    ospam -v normal.sgml >tmp.result 2>&1 &
    SLEEP_WAIT 1
    test "$(grep -Eo "[0-9]\.[0-9]\.[0-9]" tmp.result)" == "$(rpm -qa opensp | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    ospam --help | grep -i 'usage'
    CHECK_RESULT $?
    ospam -c SYSTEM normal.sgml 2>&1 | grep 'Hello'
    CHECK_RESULT $?
    ospam -C catalogs | grep 'Hello'
    CHECK_RESULT $?
    mkdir testdir && cp -rf normal.sgml ./testdir/
    ospam -D ./testdir/ normal.sgml | grep 'Hello'
    CHECK_RESULT $?
    ospam -R -D ./testdir/ normal.sgml | grep 'Hello'
    CHECK_RESULT $?
    ospam -n normal.sgml | grep 'Hello'
    CHECK_RESULT $?
    ospam -r normal.sgml | grep 'Hello'
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf testdir catalogs normal*.sgml ./*.log tmp.result
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
