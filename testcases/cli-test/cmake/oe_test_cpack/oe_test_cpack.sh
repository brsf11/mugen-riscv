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
# @Date      :   2020/10/13
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of cpack command
# ############################################

source "../common/common_cmake.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cpack --help | grep -E "Usage|cpack \[options\]"
    CHECK_RESULT $?
    cpack --version | grep "cpack version"
    CHECK_RESULT $?
    cpack --help-full | grep "variable"
    CHECK_RESULT $?
    cpack --help-manual-list | grep "cmake"
    CHECK_RESULT $?
    cpack --help-command include_directories | grep "include_directories"
    CHECK_RESULT $?
    cpack --help-command-list | grep -E "add_executable|include_directories|aux_source_directory"
    CHECK_RESULT $?
    cmake ..
    CHECK_RESULT $?
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f Makefile -a -f CPackConfig.cmake -a -f CPackSourceConfig.cmake
    CHECK_RESULT $?
    cpack -G "7Z" | grep "CPack: Create package using 7Z"
    CHECK_RESULT $?
    test -d _CPack_Packages
    CHECK_RESULT $?
    test -f demo1-1.0.0-Linux.7z -a -f install_manifest.txt -a -f main
    CHECK_RESULT $?
    cpack -C "Debug" -G "STGZ" | grep -E "CPack: Create package using STGZ|demo \[Debug\]"
    CHECK_RESULT $?
    test -f demo1-1.0.0-Linux.sh
    CHECK_RESULT $?
    cpack -D CPACK_GENERATOR=ZIP | grep "CPack: Create package using ZIP"
    CHECK_RESULT $?
    test -f demo1-1.0.0-Linux.zip
    CHECK_RESULT $?
    cpack --config CPackConfig.cmake -G "TGZ" | grep "CPack: Create package using TGZ"
    CHECK_RESULT $?
    test -f demo1-1.0.0-Linux.tar.gz
    CHECK_RESULT $?
    cpack --verbose -G "TZ" | grep "CPack: Enable Verbose"
    CHECK_RESULT $?
    test -f demo1-1.0.0-Linux.tar.Z
    CHECK_RESULT $?
    cpack --debug -G "TXZ" | grep "Enable Debug"
    CHECK_RESULT $?
    test -f demo1-1.0.0-Linux.tar.xz
    CHECK_RESULT $?
    cpack -P "testpack" -G "STGZ"
    CHECK_RESULT $?
    grep -a "testpack Installer Version: 1.0.0, Copyright (c) demo1" demo1-1.0.0-Linux.sh
    CHECK_RESULT $?
    cpack -R "2.2.3" -G "STGZ"
    CHECK_RESULT $?
    grep -a "demo1 Installer Version: 2.2.3, Copyright (c) demo1" demo1-1.0.0-Linux.sh
    CHECK_RESULT $?
    OPENEULER_VERSION=$(awk '{print$3}' /etc/openEuler-release)
    if [ ${OPENEULER_VERSION} != 20.03 ]; then
        cpack -B cpackdir -G "STGZ" | grep "cpackdir/demo1-1.0.0-Linux.sh generated."
    else
        currentDir=$(
            cd "$(dirname $0)" || exit 1
            pwd
        )
        cpack -B $currentDir/cpackdir -G "STGZ" | grep "cpackdir/demo1-1.0.0-Linux.sh generated."
    fi
    test -d cpackdir -a -d cpackdir/_CPack_Packages
    CHECK_RESULT $?
    test -f cpackdir/demo1-1.0.0-Linux.sh
    CHECK_RESULT $?
    cpack --vendor "Huawei" -G "STGZ"
    CHECK_RESULT $?
    grep -a "demo1 Installer Version: 1.0.0, Copyright (c) Huawei" demo1-1.0.0-Linux.sh
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
