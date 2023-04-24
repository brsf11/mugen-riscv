#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.


source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    rpm -q gcc | grep gcc
    CHECK_RESULT $?
    rpm -q llvm | grep llvm
    CHECK_RESULT $?
    rpm -q clang | grep clang
    CHECK_RESULT $?
    rpm -q glibc | grep glibc
    CHECK_RESULT $?
    rpm -q libstdc++ | grep libstdc++
    CHECK_RESULT $?
    rpm -q libffi | grep libffi
    CHECK_RESULT $?
    rpm -q libnet | grep libnet
    CHECK_RESULT $?
    rpm -q libevent | grep libevent
    CHECK_RESULT $?
    rpm -q libcurl | grep libcurl
    CHECK_RESULT $?
    rpm -q freetype | grep freetype
    CHECK_RESULT $?
    rpm -q zlib | grep zlib
    CHECK_RESULT $?
    rpm -q openssl | grep openssl
    CHECK_RESULT $?
    rpm -q ncurses | grep ncurses
    CHECK_RESULT $?
    rpm -q nss | grep nss
    CHECK_RESULT $?
    rpm -q pango | grep pango
    CHECK_RESULT $?
    rpm -q cairo | grep cairo
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

main "$@"