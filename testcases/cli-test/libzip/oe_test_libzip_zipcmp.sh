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
#@Date      	:   2020-10-09
#@License   	:   Mulan PSL v2
#@Desc      	:   command test-zipcmp
#####################################
source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL libzip
    mkdir testdir1 testdir2
    echo "hello" >testdir1/testfile1
    echo "hello" >testdir1/testA
    echo "hello" >testdir2/testfile2
    echo "HELlo" >testdir2/testa
    zip -r testdir1.zip testdir1/
    zip -r testdir2.zip testdir2/
    cp -r testdir2.zip testdir3.zip
    echo "world" >testdir2/testfile2
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    zipcmp -h | grep -i "usage"
    CHECK_RESULT $?
    test "$(zipcmp -V | grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa libzip | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    zipcmp -i testdir1.zip testdir2.zip | grep -e "testdir1/testA" -e "testdir2/testa"
    CHECK_RESULT $?
    zipcmp -i testdir2.zip testdir3.zip
    CHECK_RESULT $?
    zipcmp -p testdir1.zip testdir2.zip | grep -e "testdir1/testA" -e "testdir2/testa"
    CHECK_RESULT $?
    zipcmp -p testdir2.zip testdir3.zip
    CHECK_RESULT $?
    zipcmp -q testdir1.zip testdir2.zip
    CHECK_RESULT $? 1
    zipcmp -q testdir2.zip testdir3.zip
    CHECK_RESULT $?
    zipcmp -t testdir1.zip testdir2.zip | grep -e "testdir1/testA" -e "testdir2/testa"
    CHECK_RESULT $?
    zipcmp -t testdir2.zip testdir3.zip
    CHECK_RESULT $?
    zipcmp -v testdir1.zip testdir2.zip | grep -e "testdir1/testA" -e "testdir2/testa"
    CHECK_RESULT $?
    zipcmp -v testdir2.zip testdir3.zip
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf testdir* test*.zip
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
