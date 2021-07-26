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
# @Desc      :   verify the uasge of cmake3 command
# ############################################

source "../common/common_cmake.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cmake3 -help | grep -E "Usage|cmake \[options]\ <path-to-source>"
    CHECK_RESULT $?
    cmake3 -version | grep "cmake version"
    CHECK_RESULT $?
    cmake3 --help-full | grep "variable"
    CHECK_RESULT $?
    cmake3 --help-command aux_source_directory | grep "aux_source_directory"
    CHECK_RESULT $?
    cmake3 --help-manual-list | grep "cmake"
    CHECK_RESULT $?
    cmake3 --help-command-list | grep -E "add_executable|include_directories|aux_source_directory"
    CHECK_RESULT $?
    cmake3 -S ../../common/ -B ../builddir3
    CHECK_RESULT $?
    test -d ../builddir3/CMakeFiles
    CHECK_RESULT $?
    test -f ../builddir3/CMakeCache.txt -a -f ../builddir3/cmake_install.cmake -a -f ../builddir3/Makefile
    CHECK_RESULT $?
    cmake3 -C ../../common/mysettings.cmake ../../common/ | grep -E 'Install configuration: "Debug"|Build files have been written to:'
    CHECK_RESULT $?
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f Makefile
    CHECK_RESULT $?
    rm -rf ./*
    cmake3 -DCMAKE_BUILD_TYPE:STRING=Debug ../../common/
    CHECK_RESULT $?
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f Makefile
    CHECK_RESULT $?
    rm -rf ./*
    cmake3 -UCMAKE_BUILD_TYPE ../../common/
    CHECK_RESULT $?
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f Makefile
    CHECK_RESULT $?
    rm -rf ./*
    cmake3 -G "Unix Makefiles" ../../common/
    CHECK_RESULT $?
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f Makefile
    CHECK_RESULT $?
    rm -rf ./*
    cmake3 -G "Ninja" ../../common/
    CHECK_RESULT $?
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f build.ninja
    rm -rf ./*
    cmake3 -E environment | grep -E "SHELL=/bin/bash|_=/usr/bin/cmake3"
    CHECK_RESULT $?
    cmake3 -E touch testCommand
    CHECK_RESULT $?
    test -f testCommand && rm -rf testCommand
    cmake3 -L A ../../common/ | grep -E "CMAKE_BUILD_TYPE:STRING=|CMAKE_INSTALL_PREFIX:PATH=/usr/local"
    CHECK_RESULT $?
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f Makefile
    CHECK_RESULT $?
    cmake3 --build ./ | grep "\[100%\] Built target main"
    CHECK_RESULT $?
    test -f main
    CHECK_RESULT $?
    ./main | grep "Hello World"
    CHECK_RESULT $?
    cmake3 -N ../../common/
    CHECK_RESULT $?
    cmake3 -P ../../common/mysettings.cmake ../../common/  | grep 'Install configuration: "Debug"'
    CHECK_RESULT $?
    rm -rf ./*
    cmake3 --debug-output ../../common/ | grep "Called from:"
    CHECK_RESULT $?
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f Makefile
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
