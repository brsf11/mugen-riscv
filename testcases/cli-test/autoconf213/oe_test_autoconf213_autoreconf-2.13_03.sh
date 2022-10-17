#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##################################
# @Author    :   LiuZiyi
# @Contact   :   lavandejoey@outlook.com
# @Date      :   2022/6/23
# @Desc      :   Test "autoreconf-2.13" command
# ##################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL autoconf213
    dir=$(pwd)
    # test_macro
    cd common || exit
    cp -r /usr/share/autoconf-2.13 test-macro
    # init configure files
    cp configure_autoreconf.in configure.in
    autoconf-2.13 2>&1
    cp configure configure.bak
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    # with custom MACRO [--macrodir=dir]
    sed -i 's/Makefile/Makefilere/g' configure.in
    autoreconf-2.13 --macrodir=test-macro 2>&1
    CHECK_RESULT $? 0 0 "Error: autoreconf-2.13 [--macrodir] run failed."
    test -f configure
    CHECK_RESULT $? 0 0 "Error: [--macrodir] configure file failed to generate."
    diff configure configure.bak | grep "Makefilere"
    CHECK_RESULT $? 0 0 "Error: autoreconf [--macrodir] failed to re-config."
    sed -i 's/Makefilere/Makefile/g' configure.in
    \cp -f configure.bak configure
    # [--verbose]
    rm -rf configure
    sed -i 's/Makefile/Makefilere/g' configure.in
    autoreconf-2.13 --verbose 2>&1 | grep "running"
    CHECK_RESULT $? 0 0 "Error: autoreconf-2.13 [--verbose] run failed."
    test -f configure
    CHECK_RESULT $? 0 0 "Error: [--verbose] configure file failed to generate."
    diff configure configure.bak | grep "Makefilere"
    CHECK_RESULT $? 0 0 "Error: autoreconf [--verbose] failed to re-config."
    sed -i 's/Makefilere/Makefile/g' configure.in
    \cp -f configure.bak configure
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf configure.in configure configure.bak test-macro
    cd "$dir" || exit
    LOG_INFO "End to restore the test environment."
}

main "$@"
