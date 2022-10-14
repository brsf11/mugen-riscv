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
    # [--foreign]
    rm -rf configure
    sed -i 's/Makefile/Makefilere/g' configure.in
    autoreconf-2.13 --foreign --verbose 2>&1 | grep "running"
    CHECK_RESULT $? 0 0 "Error: autoreconf-2.13 [--foreign] run failed."
    test -f configure
    CHECK_RESULT $? 0 0 "Error: [--foreign] configure file failed to generate."
    diff configure configure.bak | grep "Makefilere"
    CHECK_RESULT $? 0 0 "Error: autoreconf [--foreign] failed to re-config."
    sed -i 's/Makefilere/Makefile/g' configure.in
    \cp -f configure.bak configure
    # [--gnits]
    rm -rf configure
    sed -i 's/Makefile/Makefilere/g' configure.in
    autoreconf-2.13 --gnits --verbose 2>&1 | grep "running"
    CHECK_RESULT $? 0 0 "Error: autoreconf-2.13 [--gnits] run failed."
    test -f configure
    CHECK_RESULT $? 0 0 "Error: [--gnits] configure file failed to generate."
    diff configure configure.bak | grep "Makefilere"
    CHECK_RESULT $? 0 0 "Error: autoreconf [--gnits] failed to re-config."
    sed -i 's/Makefilere/Makefile/g' configure.in
    \cp -f configure.bak configure
    # [--gnu]
    rm -rf configure
    sed -i 's/Makefile/Makefilere/g' configure.in
    autoreconf-2.13 --gnu --verbose 2>&1 | grep "running"
    CHECK_RESULT $? 0 0 "Error: autoreconf-2.13 [--gnu] run failed."
    test -f configure
    CHECK_RESULT $? 0 0 "Error: [--gnu] configure file failed to generate."
    diff configure configure.bak | grep "Makefilere"
    CHECK_RESULT $? 0 0 "Error: autoreconf [--gnu] failed to re-config."
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
