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
    jemalloc-config --help | grep 'Usage'
    CHECK_RESULT $?
    test $(jemalloc-config --version | awk -F '-' '{print $1}') = $(rpm -qa jemalloc | awk -F '-' '{print $2}')
    CHECK_RESULT $?
    jemalloc-config --revision | grep [0-9]
    CHECK_RESULT $?
    jemalloc-config --config | grep '\--build\|\--host\|\--program-prefix'
    CHECK_RESULT $?
    jemalloc-config --prefix | grep '/usr'
    CHECK_RESULT $?
    jemalloc-config --bindir | grep '/usr/bin'
    CHECK_RESULT $?
    jemalloc-config --datadir | grep '/usr/share'
    CHECK_RESULT $?
    jemalloc-config --includedir | grep '/usr/include'
    CHECK_RESULT $?
    jemalloc-config --libdir | grep '/usr/lib64'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
