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
#@Desc      	:   command test-zipmerge
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
    zip -r testdir4.zip testdir2/
    cp -r testdir4.zip testdir5.zip
    cp -r testdir1.zip testdir6.zip
    cp -r testdir2.zip testdir7.zip
    cp -r testdir2.zip testdir8.zip
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    zipmerge -h | grep -i "usage"
    CHECK_RESULT $?
    test "$(zipmerge -V | grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa libzip | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    zipmerge -D testdir2.zip testdir3.zip 2>&1 | grep -i "File already exists"
    CHECK_RESULT $?
    zipmerge -D testdir1.zip testdir3.zip && unzip testdir1.zip -d tmp1 | grep testdir2
    CHECK_RESULT $?
    zipmerge -I testdir1.zip testdir5.zip && unzip testdir1.zip -d tmp2 &&
        grep "world" tmp2/testdir2/testfile2
    CHECK_RESULT $?
    grep "hello" tmp2/testdir2/testfile2
    CHECK_RESULT $? 0 1
    echo -e "y\\ny\\ny\\n" | zipmerge -i testdir6.zip testdir3.zip &&
        unzip testdir1.zip -d tmp3 | grep testdir2
    CHECK_RESULT $?
    zipmerge -S testdir7.zip testdir4.zip && unzip testdir7.zip -d tmp4 &&
        grep "world" tmp4/testdir2/testfile2
    CHECK_RESULT $?
    echo -e "y\r" | zipmerge -i -s testdir8.zip testdir4.zip &&
        unzip testdir8.zip -d tmp5 && grep "world" tmp5/testdir2/testfile2
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf testdir* test*.zip tmp*
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
