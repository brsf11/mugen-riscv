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
#@Author    	:   wangxiaorou
#@Contact   	:   wangxiaorou@uniontech.com
#@Date      	:   2022-08-11
#@License   	:   Mulan PSL v2
#@Desc      	:   Check password ciphertext unique
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    id normal && userdel -rf normal
    useradd normal
    echo "${NODE1_PASSWORD}" |passwd normal --stdin
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ciphertext_root_1=$(getent shadow root |awk -F ":" '{print $2}' | awk -F "\$" '{print $4}')
    ciphertext_normal_1=$(getent shadow normal |awk -F ":" '{print $2}' | awk -F "\$" '{print $4}')
    CHECK_RESULT "${ciphertext_root_1}"  "${ciphertext_normal_1}"  1 "ciphertext check failed"

    echo "${NODE1_PASSWORD}" |passwd root --stdin
    echo "${NODE1_PASSWORD}" |passwd normal --stdin
    ciphertext_root_2=$(getent shadow root |awk -F ":" '{print $2}' | awk -F "\$" '{print $4}')
    ciphertext_normal_2=$(getent shadow normal |awk -F ":" '{print $2}' | awk -F "\$" '{print $4}')
    CHECK_RESULT "${ciphertext_root_2}"  "${ciphertext_normal_2}"  1 "ciphertext check failed"
    CHECK_RESULT "${ciphertext_root_2}"  "${ciphertext_root_1}"  1 "ciphertext check failed"
    CHECK_RESULT "${ciphertext_normal_2}"  "${ciphertext_normal_1}"  1 "ciphertext check failed"

    NEW_PWD="openeuler12#$"
    echo "${NEW_PWD}" |passwd root --stdin
    echo "${NEW_PWD}" |passwd normal --stdin
    ciphertext_root_3=$(getent shadow root |awk -F ":" '{print $2}' | awk -F "\$" '{print $4}')
    ciphertext_normal_3=$(getent shadow normal |awk -F ":" '{print $2}' | awk -F "\$" '{print $4}')
    CHECK_RESULT "${ciphertext_root_3}"  "${ciphertext_normal_3}"  1 "ciphertext check failed"
    CHECK_RESULT "${ciphertext_root_3}"  "${ciphertext_root_2}"  1 "ciphertext check failed"
    CHECK_RESULT "${ciphertext_normal_3}"  "${ciphertext_normal_2}"  1 "ciphertext check failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    userdel -rf normal
    echo "${NODE1_PASSWORD}" |passwd root --stdin
    LOG_INFO "End to restore the test environment."
}

main "$@"

