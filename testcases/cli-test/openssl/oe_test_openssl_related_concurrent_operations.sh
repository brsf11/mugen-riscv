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
#@Date          :   2020-07-27
#@License       :   Mulan PSL v2
#@Desc          :   Pressure load : different but related operations are performed concurrently
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    cat >word <<EOF
    This is a file created by shell.
    We want to make a good world.
    Byebye!
EOF
    openssl enc -e -des3 -a -salt -in word -out encword -pass pass:123456
    CHECK_RESULT $?
    openssl enc -d -des3 -a -salt -in encword -out decword -pass pass:123456
    for i in $(seq 1 200); do
        {
            openssl enc -e -des3 -a -salt -in word -out encword_$i -pass pass:123456
            CHECK_RESULT $?
            openssl enc -d -des3 -a -salt -in encword -out decword_$i -pass pass:123456
            CHECK_RESULT $?
        } &
    done
    SLEEP_WAIT 3
    for i in $(seq 1 200); do
        grep "U2FsdGVkX1" encword_$i
        CHECK_RESULT $?
        test -f decword_$i && diff decword_$i decword
        CHECK_RESULT $?
    done
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f word encword* decword*
    LOG_INFO "End to restore the test environment."
}

main "$@"
