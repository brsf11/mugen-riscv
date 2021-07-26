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
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-10-13
#@License       :   Mulan PSL v2
#@Desc          :   Colm is a programming language designed for the analysis and transformation of computer languages.
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "colm colm-devel"
    touch mu.txt
    cat >zjl.c <<EOF
#include<stdio.h>

int main()
{
int i,j,k;
printf("\\n");
for(i=1;i<5;i++) {
    for(j=1;j<5;j++) {
        for (k=1;k<5;k++) {
            if (i!=k&&i!=j&&j!=k) {
                printf("%d,%d,%d\\n",i,j,k);
                }
            }
        }
    }
}
EOF
    gcc zjl.c -o zhu
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    colm --help | grep 'usage'
    CHECK_RESULT $?
    colm --version | grep "Colm version"
    CHECK_RESULT $?
    colm -b zhu mu.txt -d | grep 'compiling with'
    CHECK_RESULT $?
    test -f mu.c -a -f mu
    CHECK_RESULT $?
    file mu | grep 'executable'
    CHECK_RESULT $?
    grep 'zhu_read_reduce' mu.c
    CHECK_RESULT $?
    colm -o zhu mu.txt
    CHECK_RESULT $?
    grep 'colm_object_read_reduce' zhu.c
    CHECK_RESULT $?
    colm -e zhu mu.txt
    CHECK_RESULT $?
    test -f mu.c -a -f mu
    CHECK_RESULT $?
    file mu | grep 'executable'
    CHECK_RESULT $?
    grep 'colm_object_read_reduce' mu.c
    CHECK_RESULT $?
    rm -f mu mu.c zhu
    gcc zjl.c -o zhu
    colm -x zhu mu.txt
    CHECK_RESULT $?
    test -f mu.c -a -f mu
    CHECK_RESULT $?
    file zhu | grep 'ASCII text'
    CHECK_RESULT $?
    rm -f mu mu.c zhu
    gcc zjl.c -shared -fPIC -o zhu
    colm -a zhu mu.txt
    CHECK_RESULT $?
    test -f mu.c -a -f mu
    CHECK_RESULT $?
    file mu | grep 'executable'
    CHECK_RESULT $?
    colm -E N=V mu.txt
    CHECK_RESULT $?
    colm -I /tmp/colm/include_path mu.txt
    CHECK_RESULT $?
    colm -i mu.txt
    CHECK_RESULT $?
    colm -L /tmp/colm/library_path mu.txt
    CHECK_RESULT $?
    colm -l mu.txt
    CHECK_RESULT $?
    colm -c mu.txt
    CHECK_RESULT $?
    colm -b zhu mu.txt -V | grep 'digraph'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -f mu mu.c mu.txt zjl.c zhu zhu.c
    LOG_INFO "End to restore the test environment."
}

main "$@"
