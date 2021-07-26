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
#@Desc      	:   command test-ziptool
#####################################
source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL libzip
    mkdir testdir5
    zip -r testdir5.zip testdir5/
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ziptool testdir5.zip add teststring.txt '\"This is a test.\n\"'
    CHECK_RESULT $?
    ziptool testdir5.zip cat 1 | grep "This is a test"
    CHECK_RESULT $?
    ziptool testdir5.zip add_dir test5
    CHECK_RESULT $?
    unzip testdir5.zip -d tmp1 | grep test5
    CHECK_RESULT $?
    ziptool -e testdir5.zip add_dir test5
    CHECK_RESULT $? 1
    ziptool -c testdir5.zip delete 2
    CHECK_RESULT $?
    unzip testdir5.zip -d tmp2 | grep test5
    CHECK_RESULT $? 1
    ziptool testdir5.zip get_archive_comment | grep "Archive comment:"
    CHECK_RESULT $?
    ziptool testdir5.zip set_archive_comment testabc
    CHECK_RESULT $?
    ziptool testdir5.zip get_archive_comment | grep "Archive comment: testabc"
    CHECK_RESULT $?
    ziptool -n testdir5.zip rename 1 abc.txt
    CHECK_RESULT $?
    unzip testdir5.zip -d tmp3 | grep "abc.txt"
    CHECK_RESULT $?
    ziptool testdir5.zip stat 1
    CHECK_RESULT $?
    ziptool testdir5.zip set_file_mtime 1 1569902400
    CHECK_RESULT $?
    ziptool testdir5.zip stat 1 | grep "2019"
    CHECK_RESULT $?
    ziptool testdir5.zip add teststring.txt 'testfile'
    CHECK_RESULT $?
    ziptool testdir5.zip set_file_mtime_all 1443672000
    CHECK_RESULT $?
    ziptool testdir5.zip stat 0 | grep "2015"
    CHECK_RESULT $?
    ziptool testdir5.zip stat 1 | grep "2015"
    CHECK_RESULT $?
    ziptool testdir5.zip stat 2 | grep "2015"
    CHECK_RESULT $?
    ziptool -h | grep -i "usage"
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
