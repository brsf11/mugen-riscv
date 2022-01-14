#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
# #############################################
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2021-11-01
# @License   :   Mulan PSL v2
# @Desc      :   exrstdattr
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rubygem-bundler
    bundle init
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    bundle update --conservative | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --conservative failed."
    bundle update --full-index | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --full-index failed."
    bundle update -j 2 | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update -j failed."
    bundle update --strict | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --strict failed."
    bundle update --quiet | grep "Bundle updated!"
    CHECK_RESULT $? 1 0 "Check bundle update --quiet failed."
    bundle update --redownload | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --redownload failed."
    bundle update --patch | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --patch failed."
    bundle update --minor | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --minor failed."
    bundle update --major | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --major failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
