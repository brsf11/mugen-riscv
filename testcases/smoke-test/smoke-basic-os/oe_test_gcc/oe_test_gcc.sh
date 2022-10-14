#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   gaoshuaishuai
# @Contact   :   gaoshuaishuai@uniontech.com
# @Date      :   2022.8.21
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-gcc
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test(){
    LOG_INFO "Start environment preparation."
    mkdir /tmp/test
    path=/tmp/test
    cat > ${path}/test1.c  <<EOF
#include <stdio.h>
int main()
{
    printf("hello world!\n");
    return 0;
}
EOF
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    gcc -o ${path}/a.out ${path}/test1.c
    ls ${path}/a.out
    CHECK_RESULT $? 0 0 "gcc file fails"
    ${path}/a.out > ${path}/tmp.1 2>&1
    CHECK_RESULT $? 0 0 "Compilation fails"
    grep "hello world!" ${path}/tmp.1
    CHECK_RESULT $? 0 0 "Compilation fails"

    gcc ${path}/test1.c -o ${path}/test2
    ls ${path}/test2
    CHECK_RESULT $? 0 0 "gcc -o file fails"
    ${path}/test2 > ${path}/tmp.2 2>&1
    CHECK_RESULT $? 0 0 "test2 Compilation fails"
    grep "hello world!" ${path}/tmp.2
    CHECK_RESULT $? 0 0 "nothingness hello word"

    gcc -E ${path}/test1.c -o ${path}/test.i
    ls ${path}/test.i
    CHECK_RESULT $? 0 0 "gcc -E file fails"

    gcc -S ${path}/test.i -o ${path}/test.s
    ls ${path}/test.s
    CHECK_RESULT $? 0 0 "gcc -S file fails"

    gcc -c ${path}/test.s -o ${path}/test.o
    ls ${path}/test.o
    CHECK_RESULT $? 0 0 "gcc -c file fails"

    gcc ${path}/test.o -o ${path}/test1
    ls ${path}/test1
    CHECK_RESULT $? 0 0 "tset1 Generate failure"
    ${path}/test1 > ${path}/tmp.3 2>&1
    CHECK_RESULT $? 0 0 "test1 Compilation fails"
    grep "hello world!" ${path}/tmp.3
    CHECK_RESULT $? 0 0 "test1 Compilation fails"

    gcc -g ${path}/test1.c -o ${path}/test1_d
    ls ${path}/test1_d
    CHECK_RESULT $? 0 0 "gcc -d file fails"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ${path}
    LOG_INFO "Finish environment cleanup!"
}

main $@
