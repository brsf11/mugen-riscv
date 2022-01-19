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
#@Desc      	:   command test-osgmlnorm
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
    osgmlnorm -b utf-8 normal.sgml | grep "Hello world"
    CHECK_RESULT $?
    osgmlnorm -f error_info.log normal.sgml | grep "Hello world" && test -f error_info.log
    CHECK_RESULT $?
    test "$(osgmlnorm -v normal.sgml 2>&1 | grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa opensp | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    osgmlnorm --help | grep -i 'usage'
    CHECK_RESULT $?
    osgmlnorm -c SYSTEM normal.sgml | grep 'Hello'
    CHECK_RESULT $?
    osgmlnorm -C catalogs | grep "Hello world"
    CHECK_RESULT $?
    mkdir testdir && cp -rf normal.sgml ./testdir/
    osgmlnorm -D ./testdir/ normal.sgml | grep "Hello world"
    CHECK_RESULT $?
    osgmlnorm -R -D ./testdir/ normal.sgml | grep "Hello world"
    CHECK_RESULT $?
    osgmlnorm -n normal.sgml | grep "Hello world"
    CHECK_RESULT $?
    osgmlnorm -r normal.sgml
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
