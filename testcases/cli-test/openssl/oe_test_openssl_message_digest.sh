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
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-07-21 17:40:00
#@License       :   Mulan PSL v2
#@Desc          :   OpenSSL commandline tool: message digest algorithm
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    echo "It is a test" >file.txt
    openssl dgst -sha1 file.txt | grep "SHA1(file.txt)"
    CHECK_RESULT $?
    openssl sha1 -out digest.txt file.txt
    CHECK_RESULT $?
    grep "SHA1(file.txt)" digest.txt
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f file.txt digest.txt
    LOG_INFO "End to restore the test environment."
}

main "$@"
