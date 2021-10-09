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
#@Desc      	:   command test-dos2unix test-unix2dos test-mac2unix test-unix2mac
#####################################

# unix format end of line "\n"
# mac  format end of line "\r"
# dos  format end of line "\r\n"

source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL dos2unix
    TESTFILE="/tmp/testfile"
    echo "test" > "${TESTFILE}"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    [[ $(od -c "${TESTFILE}" | sed -n '1p') == "0000000   t   e   s   t  \n"  ]]
    CHECK_RESULT $? 0 0 "The original file format is not unix"

    LOG_INFO "test cmd unix2dos..."
    unix2dos "${TESTFILE}"
    CHECK_RESULT $? 0 0 "unix2dos cmd exec failed"
    [[ $(od -c "${TESTFILE}" | sed -n '1p') == "0000000   t   e   s   t  \r  \n"  ]]
    CHECK_RESULT $? 0 0 "unix2dos result error, please check..."

    LOG_INFO "test cmd dos2unix..."
    dos2unix "${TESTFILE}"
    CHECK_RESULT $? 0 0 "dos2unix cmd exec failed"
    [[ $(od -c "${TESTFILE}" | sed -n '1p') == "0000000   t   e   s   t  \n"  ]]
    CHECK_RESULT $? 0 0 "dos2unix result error, please check..."

    LOG_INFO "test cmd unix2mac..."
    unix2mac "${TESTFILE}"
    CHECK_RESULT $? 0 0 "unix2mac cmd exec failed"
    [[ $(od -c "${TESTFILE}" | sed -n '1p') == "0000000   t   e   s   t  \r"  ]]
    CHECK_RESULT $? 0 0 "unix2mac result error, please check..."

    LOG_INFO "test cmd mac2unix..."
    mac2unix "${TESTFILE}"
    CHECK_RESULT $? 0 0 "mac2unix cmd exec failed"
    [[ $(od -c "${TESTFILE}" | sed -n '1p') == "0000000   t   e   s   t  \n"  ]]
    CHECK_RESULT $? 0 0 "mac2unix result error, please check..."

    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -f "${TESTFILE}"
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
