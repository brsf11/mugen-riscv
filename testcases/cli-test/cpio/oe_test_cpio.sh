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
#@Author    	:   wangqing
#@Contact   	:   wangqing@uniontech.com
#@Date      	:   2021-07-12
#@License   	:   Mulan PSL v2
#@Desc      	:   command test-cpio
#####################################


source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL cpio

    mkdir "testdir"
    for i in {a..z}; do
        echo "Test" > "testdir/${i}"
    done

    find testdir -type f > filelist

    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    LOG_INFO "test cpio -o option"
    cpio -o > cpio.out < filelist
    CHECK_RESULT $? 0 0 "failed to cpio create..."

    LOG_INFO "test cpio -t option"
    mv "filelist" "filelist_orig"
    cpio -t < cpio.out > filelist
    CHECK_RESULT $? 0 0 "failed to cpio list..."
    diff -r "filelist" "filelist_orig"
    CHECK_RESULT $? 0 0 "cpio list results are inconsistent..."

    LOG_INFO "test cpio -I option"
    mv "filelist" "filelist_orig"
    cpio -tI  cpio.out > filelist
    CHECK_RESULT $? 0 0 "failed to cpio option -I..."
    diff -r "filelist" "filelist_orig"
    CHECK_RESULT $? 0 0 "cpio list with -I results are inconsistent..."

    LOG_INFO "test cpio -i option"
    mv "testdir" "testdir_orig"
    mkdir "testdir"
    CHECK_RESULT $? 0 0 "failed create testdir..."
    cpio -i < cpio.out
    CHECK_RESULT $? 0 0 "failed to cpio extract..."
    diff -r "testdir" "testdir_orig"
    CHECK_RESULT $? 0 0 "cpio create and extract results are inconsistent..."

    LOG_INFO "test cpio -u option"
    for i in {a..z}; do
        echo "Hello" > "testdir/${i}"
    done
    cpio -iu < cpio.out
    CHECK_RESULT $? 0 0 "failed to cpio extract with -u -i option..."
    diff -r "testdir" "testdir_orig"
    CHECK_RESULT $? 0 0 "cpio -i -u option test failed..."

    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf "cpio.out"  "filelist" "filelist_orig" "testdir"  "testdir_orig"
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
