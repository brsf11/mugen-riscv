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
# @Desc      :   Test "autoupdate-2.13" command
# ##################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL autoconf213
    # init test files
    dir=$(pwd)
    cd common || exit
    cp configure_autoconf.in configure.in
    # test_macro
    cp -r /usr/share/autoconf-2.13 test-macro
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    autoupdate-2.13 --help 2>&1 | grep "Usage: autoupdate"
    CHECK_RESULT $? 0 0 "Error: autoupdate-2.13 --help run failed"
    autoupdate-2.13 --h 2>&1 | grep "Usage: autoupdate"
    CHECK_RESULT $? 0 0 "Error: autoupdate-2.13 -h run failed"
    autoupdate-2.13 --version 2>&1 | grep "Autoconf version"
    CHECK_RESULT $? 0 0 "Error: autoupdate-2.13 --version run failed"
    autoupdate-2.13 2>&1
    CHECK_RESULT $? 0 0 "Error: autoupdate-2.13 run failed."
    test -f configure.in~
    CHECK_RESULT $? 0 0 "Error: configure~ file failed to generate."
    rm -rf configure.in~
    # with custom MACRO [--macrodir=dir] [-m dir]
    autoupdate-2.13 --macrodir=test-macro 2>&1
    CHECK_RESULT $? 0 0 "Error: autoupdate-2.13 [--macrodir] run failed."
    test -f configure.in~
    CHECK_RESULT $? 0 0 "Error: [--macrodir] configure file failed to generate."
    rm -rf configure.in~
    autoupdate-2.13 -m test-macro 2>&1
    CHECK_RESULT $? 0 0 "Error: autoupdate-2.13 [-m dir] run failed."
    test -f configure.in~
    CHECK_RESULT $? 0 0 "Error: [-m dir] configure file failed to generate."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf configure.in* test-macro
    cd "$dir" || exit
    LOG_INFO "End to restore the test environment."
}

main "$@"
