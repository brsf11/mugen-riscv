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
#@Date          :   2020-10-10
#@License       :   Mulan PSL v2
#@Desc          :   Jemalloc is a memory allocator, the biggest advantage is: high performance in the case of multithreading and the reduction of memory fragmentation.
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL jemalloc
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    jemalloc-config --mandir | grep '/usr/share/man'
    CHECK_RESULT $?
    jemalloc-config --cc | grep 'gcc'
    CHECK_RESULT $?
    jemalloc-config --cflags | grep '\-std\|\-Wundef'
    CHECK_RESULT $?
    jemalloc-config --cppflags | grep 'D_GNU_SOURCE'
    CHECK_RESULT $?
    jemalloc-config --cxxflags | grep 'openEuler-hardened-cc1\|generic-hardened-cc1'
    CHECK_RESULT $?
    jemalloc-config --ldflags | grep 'openEuler-hardened-ld\|generic-hardened-ld'
    CHECK_RESULT $?
    jemalloc-config --libs | grep 'lm'
    CHECK_RESULT $?
    source /usr/bin/jemalloc.sh
    CHECK_RESULT $?
    echo ${LD_PRELOAD} | grep '/usr/lib64/libjemalloc.so.2'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
