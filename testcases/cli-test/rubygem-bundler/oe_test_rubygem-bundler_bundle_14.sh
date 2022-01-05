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
    bundle outdated | grep "Bundle up to date!"
    CHECK_RESULT $? 0 0 "Check bundle outdated failed."
    bundle outdated --local | grep "Bundle up to date!"
    CHECK_RESULT $? 0 0 "Check bundle outdated --local failed."
    bundle outdated --pre | grep "Bundle up to date!"
    CHECK_RESULT $? 0 0 "Check bundle outdated --pre failed."
    bundle outdated --source ruby | grep "Bundle up to date!"
    CHECK_RESULT $? 0 0 "Check bundle outdated --source failed."
    bundle outdated --strict | grep "Bundle up to date!"
    CHECK_RESULT $? 0 0 "Check bundle outdated --strict failed."
    bundle outdated --only-explicit | grep "Bundle up to date!"
    CHECK_RESULT $? 0 0 "Check bundle outdated --only-explicit failed."
    bundle outdated --group | grep "Bundle up to date!"
    CHECK_RESULT $? 0 0 "Check bundle outdated --group failed."
    bundle outdated --groups | grep "Bundle up to date!"
    CHECK_RESULT $? 0 0 "Check bundle outdated --groups failed."
    bundle outdated --update-strict | grep "Bundle up to date!"
    CHECK_RESULT $? 0 0 "Check bundle outdated --update-strict failed."
    bundle outdated --minor | grep "Bundle up to date!"
    CHECK_RESULT $? 0 0 "Check bundle outdated --minor failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile .bundle
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
