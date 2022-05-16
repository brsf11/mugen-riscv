#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   caimingxiang
#@Contact   	:   mingxiang@isrc.iscas.ac.cn
#@Date      	:   2022-3-8 20:50:00
#@License   	:   Mulan PSL v2
#@Desc      	:   test rpmdev-vercmp spectool
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "rpmdevtools"

    wget https://gitee.com/src-openeuler/rpmdevtools/raw/master/rpmdevtools.spec
    mkdir ./test_dir
    rpmdev-setuptree

    LOG_INFO "End of environmental preparation."
}

function run_test() {
    LOG_INFO "Start to run test."

    rpmdev-vercmp 1 1 2 2 1 2
    CHECK_RESULT $? 12 0 "Failed option: n:n-n < n:n-n"
    rpmdev-vercmp 2 1 2 1 1 2
    CHECK_RESULT $? 11 0 "Failed option: n:n-n > n:n-n"
    rpmdev-vercmp 2 1
    CHECK_RESULT $? 11 0 "Failed option: n > n"
    rpmdev-vercmp 1 2
    CHECK_RESULT $? 12 0 "Failed option: n < n"
    rpmdev-vercmp 1 1
    CHECK_RESULT $? 0 0 "Failed option: n == n"
    rpmdev-vercmp 2 1 2 2 1 2
    CHECK_RESULT $? 0 0 "Failed option: n:n-n == n:n-n"
    rpmdev-vercmp -h | grep -A 5 "rpmdev-vercmp" | grep "Exit status"
    CHECK_RESULT $? 0 0 "Failed option: -h"

    spectool -l rpmdevtools.spec | grep "Source"
    CHECK_RESULT $? 0 0 "Failed option: -l"
    spectool -g rpmdevtools.spec && test -f *tar.xz
    CHECK_RESULT $? 0 0 "Failed option: -g"
    spectool -h | grep "Usage: spectool"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    spectool -A rpmdevtools.spec | grep -A 10 "Source" | grep "Patch"
    CHECK_RESULT $? 0 0 "Failed option: -A"
    spectool -S rpmdevtools.spec | grep "Source"
    CHECK_RESULT $? 0 0 "Failed option: -S"
    spectool -P rpmdevtools.spec | grep "Patch"
    CHECK_RESULT $? 0 0 "Failed option: -P"
    spectool -s 0 rpmdevtools.spec | grep "Source0"
    CHECK_RESULT $? 0 0 "Failed option: -s"
    spectool -p 0 rpmdevtools.spec | grep "Patch0"
    CHECK_RESULT $? 0 0 "Failed option: -p"
    spectool -d 'test test1' rpmdevtools.spec
    CHECK_RESULT $? 0 0 "Failed option: -d"
    spectool -g -C ./test_dir rpmdevtools.spec && test -f ./test_dir/*tar.xz
    CHECK_RESULT $? 0 0 "Failed option: -C"
    spectool -g -R rpmdevtools.spec && test -f ~/rpmbuild/SOURCES/*tar.xz
    CHECK_RESULT $? 0 0 "Failed option: -R"
    test -f *tar.xz && spectool -g -f rpmdevtools.spec
    CHECK_RESULT $? 0 0 "Failed option: -f"
    rm *tar.gz
    spectool -g -n rpmdevtools.spec
    CHECK_RESULT $? 0 0 "Failed option: -n"
    rm -rf /tmp/spectool*
    spectool -D rpmdevtools.spec
    test $(ls -l /tmp/spectool* | wc -l) == 4
    CHECK_RESULT $? 0 0 "Failed option: -D"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./test_dir ~/rpmbuild ./rpmdevtools*
    LOG_INFO "End to restore the test environment."
}

main "$@"
