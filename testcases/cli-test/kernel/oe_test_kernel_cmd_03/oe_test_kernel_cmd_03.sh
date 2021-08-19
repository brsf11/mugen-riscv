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
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2021/01/19
# @License   :   Mulan PSL v2
# @Desc      :   Test kernel command
# ##################################
source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "kernel-tools perf bpftool jq"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    perf -h | grep usage
    CHECK_RESULT $?
    perf version | grep 'perf version'
    CHECK_RESULT $?
    perf list | awk -F: '/Tracepoint event/ { lib[$1]++ } END { for (l in lib){ printf " %-16s %d\n", l, lib[l] } }' | sort | column
    printf "#include<stdio.h>
int main()
{
        printf(\"Hello,wolrd!\\\n\");
        return 0;
}" >hello.c
    gcc hello.c
    perf stat -e task-clock ./a.out | grep "Hello,wolrd!"
    CHECK_RESULT $?
    ret=$(perf stat -r 5 ./a.out | grep -c "Hello,wolrd!")
    CHECK_RESULT "${ret}" 5
    perf stat -d ./a.out | grep "Hello,wolrd!"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the tet environment."
    DNF_REMOVE
    rm -rf hello.c a.out
    LOG_INFO "Finish to restore the tet environment."
}

main "$@"
