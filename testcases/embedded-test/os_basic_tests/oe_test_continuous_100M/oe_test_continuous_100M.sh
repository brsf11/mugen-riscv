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
# @Desc      :   100M file continuous cp,dd,tar
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    testfile1=myfile$(date +%Y%m%d)
    testfile2=mycpfile$(date +%Y%m%d)

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    for i in $(seq 1 10); do
        dd if=/dev/urandom of=${testfile1} bs=1M count=100
        CHECK_RESULT $? 0 0 "make urandom ${testfile1} file count ${i} fail"
        ls -l ${testfile1} | awk '{print$5}' | grep -w 104857600
        CHECK_RESULT $? 0 0 "check urandom file size fail"
        dd if=/dev/zero of=${testfile1} bs=1M count=100
        CHECK_RESULT $? 0 0 "make zero ${testfile1} file count ${i} fail"
        ls -l ${testfile1} | awk '{print$5}' | grep -w 104857600
        CHECK_RESULT $? 0 0 "check zero file size fail"
    done

    file_size=$(ls -l ${testfile1} | awk '{print$5}')

    for i in $(seq 1 10); do
        rm -rf ${testfile2}
        cp ${testfile1} ${testfile2}
        CHECK_RESULT $? 0 0 "copy ${testfile1} fail"
        ls -l ${testfile2} | grep ${file_size}
        CHECK_RESULT $? 0 0 "check copy file size fail"
    done

    for i in $(seq 1 10); do
        rm -rf ${testfile1}.tar
        tar -cf ${testfile1}.tar ${testfile1}
        CHECK_RESULT $? 0 0 "continuous tar file times ${i} fail"
        ls ${testfile1}.tar
        CHECK_RESULT $? 0 0 "check tar file times ${i} fail"
        tar -zcf ${testfile1}.tar.gz ${testfile1}
        CHECK_RESULT $? 0 0 "continuous tar.gz file times ${i} fail"
        ls ${testfile1}.tar.gz
        CHECK_RESULT $? 0 0 "check tar.gz file times ${i} fail"
    done

    for i in $(seq 1 10); do
        rm -rf ${testfile1}
        tar -xf ${testfile1}.tar
        CHECK_RESULT $? 0 0 "uncontinuous tar file times ${i} fail"
        ls -l ${testfile1} | grep ${file_size}
        CHECK_RESULT $? 0 0 "check tar file uncontinuous times ${i} fail"

        rm -rf ${testfile1}
        tar -zxf ${testfile1}.tar.gz
        CHECK_RESULT $? 0 0 "uncontinuous tar.gz file times ${i} fail"
        ls -l ${testfile1} | grep ${file_size}
        CHECK_RESULT $? 0 0 "check tar.gz uncontinuous times ${i} fail"
    done

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf ${testfile1} ${testfile2} ${testfile1}.zip

    LOG_INFO "End to restore the test environment."
}

main "$@"
