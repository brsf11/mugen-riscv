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
#@Date          :   2020-07-22
#@License       :   Mulan PSL v2
#@Desc          :   Encryption algorithm: symmetric encryption and decryption
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    echo "Hello, world!" >word
    openssl enc -e -des3 -a -salt -in word -out encword -pass pass:123456
    CHECK_RESULT $?
    grep "U2FsdGVkX1" encword
    CHECK_RESULT $?
    openssl enc -d -des3 -a -salt -in encword -out decword -pass pass:123456
    CHECK_RESULT $?
    test -f decword && diff word decword
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f word encword decword
    LOG_INFO "End to restore the test environment."
}

main "$@"
