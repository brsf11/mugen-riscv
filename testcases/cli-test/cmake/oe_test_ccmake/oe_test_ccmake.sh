#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/12
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of ccmake command
# ############################################

source "../common/common_cmake.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    VERSION_ID=$(awk '{print$3}' /etc/openEuler-release)
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ccmake -help | grep -E "Usage|ccmake <path-to-source>"
    CHECK_RESULT $?
    ccmake -version | grep "ccmake version"
    CHECK_RESULT $?
    ccmake --help-full | grep "variable"
    CHECK_RESULT $?
    ccmake --help-command add_executable | grep "add_executable"
    CHECK_RESULT $?
    ccmake --help-manual-list | grep "cmake"
    CHECK_RESULT $?
    if [ $VERSION_ID != "22.03" ]; then
        expect <<EOF
        spawn ccmake -B ../buildccmake -S ../../common/
        expect "EMPTY CACHE" {send "c"}
        expect "*" {send "\r"}
        expect "*" {send "Debug\r"}
        expect " " {send "c"}
        expect " " {send "g"}
        expect eof
EOF
    else
        expect <<EOF
        spawn ccmake -B ../buildccmake -S ../../common/
        expect "EMPTY CACHE" {send "c"}
        expect " " {send "e"}
        expect "*" {send "\r"}
        expect "*" {send "Debug\r"}
        expect " " {send "c"}
        expect " " {send "e"}
        expect " " {send "g"}
        expect eof
EOF
    fi

    test -d ../buildccmake/CMakeFiles
    CHECK_RESULT $?
    test -f ../buildccmake/CMakeCache.txt -a -f ../buildccmake/cmake_install.cmake -a -f ../buildccmake/Makefile
    CHECK_RESULT $?
    if [ $VERSION_ID != "22.03" ]; then
        expect <<EOF
        spawn ccmake -C ../../common/mysettings.cmake ../../common/
        expect "EMPTY CACHE" {send "c"}
        expect "*" {send "\r"}
        expect "*" {send "Debug\r"}
        expect " " {send "c"}
        expect " " {send "g"}
        expect eof
EOF
    else
        expect <<EOF
        spawn ccmake -C ../../common/mysettings.cmake ../../common/
        expect "EMPTY CACHE" {send "c"}
        expect " " {send "e"}
        expect "*" {send "\r"}
        expect "*" {send "Debug\r"}
        expect " " {send "c"}
        expect " " {send "e"}
        expect " " {send "g"}
        expect eof
EOF
    fi

    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f Makefile
    CHECK_RESULT $?
    rm -rf ./*
    if [ $VERSION_ID != "22.03" ]; then
        expect <<EOF
        spawn ccmake -DCMAKE_BUILD_TYPE:STRING=RELEASE ../../common/
        expect "CMAKE_BUILD_TYPE:" {send "c"}
        expect "CMAKE_INSTALL_PREFIX:" {send "c"}
        expect "CMAKE_BUILD_TYPE:" {send "g"}
        expect eof
EOF
    else
        expect <<EOF
        spawn ccmake -DCMAKE_BUILD_TYPE:STRING=RELEASE ../../common/
        expect "CMAKE_BUILD_TYPE:" {send "c"}
        expect " " {send "e"}
        expect "CMAKE_INSTALL_PREFIX:" {send "c"}
        expect " " {send "e"}
        expect "CMAKE_BUILD_TYPE:" {send "g"}
        expect eof
EOF
    fi 
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f Makefile
    CHECK_RESULT $?
    rm -rf ./*
    if [ $VERSION_ID != "22.03" ]; then
        expect <<EOF
        spawn ccmake -UCMAKE_BUILD_TYPE ../../common/
        expect "EMPTY CACHE" {send "c"}
        expect "*" {send "c"}
        expect "CMAKE_BUILD_TYPE:" {send "g"}
        expect eof
EOF
    else
        expect <<EOF
        spawn ccmake -UCMAKE_BUILD_TYPE ../../common/
        expect "EMPTY CACHE" {send "c"}
        expect " " {send "e"}
        expect "*" {send "c"}
        expect " " {send "e"}
        expect "CMAKE_BUILD_TYPE:" {send "g"}
        expect eof
EOF
    fi  
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f Makefile
    CHECK_RESULT $?
    rm -rf ./*
    if [ $VERSION_ID != "22.03" ]; then
        expect <<EOF
        spawn ccmake -G "Unix Makefiles" ../../common/
        expect "EMPTY CACHE" {send "c"}
        expect "*" {send "c"}
        expect "CMAKE_BUILD_TYPE:" {send "g"}
        expect eof
EOF
    else
        expect <<EOF
        spawn ccmake -G "Unix Makefiles" ../../common/
        expect "EMPTY CACHE" {send "c"}
        expect " " {send "e"}
        expect "*" {send "c"}
        expect " " {send "e"}
        expect "CMAKE_BUILD_TYPE:" {send "g"}
        expect eof
EOF
    fi 
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f Makefile
    CHECK_RESULT $?
    rm -rf ./*
    if [ $VERSION_ID != "22.03" ]; then
        expect <<EOF
        spawn ccmake -G "Ninja" ../../common/
        expect "EMPTY CACHE" {send "c"}
        expect "*" {send "c"}
        expect "CMAKE_BUILD_TYPE:" {send "g"}
        expect eof
EOF
    else
        expect <<EOF
        spawn ccmake -G "Ninja" ../../common/
        expect "EMPTY CACHE" {send "c"}
        expect " " {send "e"}
        expect "*" {send "c"}
        expect " " {send "e"}
        expect "CMAKE_BUILD_TYPE:" {send "g"}
        expect eof
EOF
    fi
    
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f build.ninja
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
