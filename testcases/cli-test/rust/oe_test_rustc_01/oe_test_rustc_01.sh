#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##############################################
# @Author    :   suhang
# @Contact   :   suhangself@163.com
# @Date      :   2021-09-22
# @License   :   Mulan PSL v2
# @Desc      :   Image compression tool rustc
# ##############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL rust
    cp ../common/hello.rs hello.rs
    cp ../common/pub.rs pub.rs
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    rustc -h |grep -i "usage"
    CHECK_RESULT $? 0 0 "Help information printing failed"
    rustc --cfg hello hello.rs
    CHECK_RESULT $?
    ls |grep -w "hello"
    CHECK_RESULT $?
    ./hello |grep "world!"
    CHECK_RESULT $? 0 0 "Failed to print world！"
    rustc -L . hello.rs --crate-name hello1
    CHECK_RESULT $?
    ls |grep "hello1"
    CHECK_RESULT $? 0 0 "Failed to output the hello1 file"
    rustc --crate-type bin pub.rs
    CHECK_RESULT $?
    ls |grep "pub"
    CHECK_RESULT $? 0 0 "Failed to output the pub file"
    rustc --crate-type lib pub.rs --crate-name _lib
    CHECK_RESULT $?
    ls |grep "lib_lib.rlib"
    CHECK_RESULT $? 0 0 "Failed to output the lib_lib.rlib file"
    rustc --crate-type rlib pub.rs --crate-name _rlib
    CHECK_RESULT $?
    ls |grep "lib_rlib.rlib"
    CHECK_RESULT $? 0 0 "Failed to output the lib_rlib.rlib file"
    rustc --crate-type dylib pub.rs --crate-name _dy
    CHECK_RESULT $?
    ls |grep "lib_dy.so"
    CHECK_RESULT $? 0 0 "Failed to output the lib_dy.so file"
    rustc --crate-type cdylib pub.rs --crate-name _cdy
    CHECK_RESULT $?
    ls |grep "lib_cdy.so"
    CHECK_RESULT $? 0 0 "Failed to output the lib_cdy.so file"
    rustc --crate-type staticlib pub.rs
    CHECK_RESULT $?
    ls |grep "libpub.a"
    CHECK_RESULT $? 0 0 "Failed to output the libpub.a file" 
    rustc pub.rs --crate-name craname
    CHECK_RESULT $?
    ls |grep "craname" 
    CHECK_RESULT $? 0 0 "Failed to output the craname file"
    rustc --edition 2018 hello.rs --crate-name editname
    CHECK_RESULT $?
    ls |grep "editname"
    CHECK_RESULT $? 0 0 "Failed to output the editname file"
    rustc --emit asm hello.rs
    CHECK_RESULT $?
    ls |grep "hello.s"
    CHECK_RESULT $? 0 0 "Failed to output the hello.s file"
    rustc --emit llvm-bc hello.rs
    CHECK_RESULT $?
    ls |grep "hello.bc"
    CHECK_RESULT $? 0 0 "Failed to output the hello.bc file"
    rustc --emit llvm-ir hello.rs
    CHECK_RESULT $?
    ls |grep "hello.ll"
    CHECK_RESULT $? 0 0 "Failed to output the hello.ll file"
    rustc --emit obj hello.rs
    CHECK_RESULT $?
    ls |grep "hello.o"
    CHECK_RESULT $? 0 0 "Failed to output the hello.o file"
    rustc --emit metadata hello.rs
    CHECK_RESULT $?
    ls |grep "hello.rmeta"
    CHECK_RESULT $? 0 0 "Failed to output the hello.rmeta file"
    rustc --emit link hello.rs --crate-name linname
    CHECK_RESULT $?
    ls |grep "linname"
    CHECK_RESULT $? 0 0 "Failed to output the linname file"
    rustc --emit dep-info hello.rs
    CHECK_RESULT $?
    ls |grep "hello.d"
    CHECK_RESULT $? 0 0 "Failed to output the hello.d file"
    rustc --emit mir hello.rs
    CHECK_RESULT $?
    ls |grep "hello.mir"
    CHECK_RESULT $? 0 0 "Failed to output the hello.mir file"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf $(ls | grep -v ".sh")
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@