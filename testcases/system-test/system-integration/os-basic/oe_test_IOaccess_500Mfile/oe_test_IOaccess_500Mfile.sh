#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   500M file continuous cp,dd,tar,zip,unzip
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to pre test."
    testfile1=myfile$(date +%Y%m%d)
    testfile2=mycpfile$(date +%Y%m%d)
    LOG_INFO "Start to pre test."
}

function run_test() {
    LOG_INFO "Start to run test."
    for i in $(seq 1 10); do
        dd if=/dev/urandom of=${testfile1} bs=1M count=500
        CHECK_RESULT $?
        ls -l ${testfile1} | awk '{print$5}' | grep -w 524288000
        CHECK_RESULT $?
        dd if=/dev/zero of=${testfile1} bs=1M count=500
        CHECK_RESULT $?
        ls -l ${testfile1} | awk '{print$5}' | grep -w 524288000
        CHECK_RESULT $?
    done

    file_size=$(ls -l ${testfile1} | awk '{print$5}')

    for i in $(seq 1 10); do
        rm -rf ${testfile2}
        cp ${testfile1} ${testfile2}
        CHECK_RESULT $?
        ls -l ${testfile2} | grep ${file_size}
        CHECK_RESULT $?
    done

    for i in $(seq 1 10); do
        rm -rf ${testfile1}.zip
        zip ${testfile1}.zip ${testfile1}
        CHECK_RESULT $?
        test -f ${testfile1}.zip
        CHECK_RESULT $?
    done

    for i in $(seq 1 10); do
        rm -rf ${testfile1}
        unzip ${testfile1}.zip
        CHECK_RESULT $?
        ls -l ${testfile1} | grep ${file_size}
        CHECK_RESULT $?
    done
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf ${testfile1} ${testfile2} ${testfile1}.zip
    LOG_INFO "End to restore the test environment."
}

main "$@"
