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
#@Date      	:   2020-12-15
#@License   	:   Mulan PSL v2
#@Desc      	:   command test-onsgmls
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
    onsgmls -b utf-8 normal.sgml | grep 'Hello'
    CHECK_RESULT $?
    onsgmls -f error_info.log normal.sgml && test -f error_info.log
    CHECK_RESULT $?
    test "$(onsgmls -v normal.sgml 2>&1 | grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa opensp | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    onsgmls --help | grep -i 'usage'
    CHECK_RESULT $?
    onsgmls -c SYSTEM normal.sgml 2>&1 | grep 'Hello'
    CHECK_RESULT $?
    onsgmls -C catalogs | grep 'Hello'
    CHECK_RESULT $?
    mkdir testdir && cp -rf normal.sgml ./testdir/
    onsgmls -D ./testdir/ normal.sgml | grep 'Hello'
    CHECK_RESULT $?
    onsgmls -R -D ./testdir/ normal.sgml | grep 'Hello'
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE 
    rm -rf testdir catalogs normal*.sgml ./*.log
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
