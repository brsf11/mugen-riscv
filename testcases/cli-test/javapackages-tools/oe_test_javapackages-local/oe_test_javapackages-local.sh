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
# @Date      :   2020/10/26
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of abs2rel and xmvn-builddep command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL javapackages-local
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    abs2rel /1/2/3/a/b/c /1/2/3 | grep "a/b/c"
    CHECK_RESULT $?
    abs2rel foo/bar foo/baz | grep "../bar"
    CHECK_RESULT $?
    gradle-local build >build.log
    xmvn-builddep --help | grep "Usage: /usr/bin/xmvn-builddep"
    CHECK_RESULT $?
    xmvn-builddep build.log
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf build.log .gradle build
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
