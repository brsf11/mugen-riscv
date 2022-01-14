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
    bundle_version=$(rpm -qa rubygem-bundler | awk -F '-' '{print $3}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    bundle version | grep "$bundle_version"
    CHECK_RESULT $? 0 0 "Check bundle version failed."
    bundle version -r 2
    CHECK_RESULT $? 0 0 "Check bundle version -r failed."
    bundle version -V | grep "$bundle_version"
    CHECK_RESULT $? 0 0 "Check bundle version -V failed."
    bundle version -h | grep "bundle version"
    CHECK_RESULT $? 0 0 "Check bundle version -h failed."
    bundle doctor
    CHECK_RESULT $? 0 0 "Check bundle doctor failed."
    bundle doctor --quiet
    CHECK_RESULT $? 0 0 "Check bundle doctor --quiet failed."
    bundle doctor --gemfile Gemfile
    CHECK_RESULT $? 0 0 "Check bundle doctor --gemfile failed."
    bundle help 2>&1 | grep "bundle COMMAND"
    CHECK_RESULT $? 0 0 "Check bundle help failed."
    bundle help -r 2 2>&1 | grep "bundle COMMAND"
    CHECK_RESULT $? 0 0 "Check bundle help -r failed."
    bundle help -V 2>&1 | grep "bundle COMMAND"
    CHECK_RESULT $? 0 0 "Check bundle help -V failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile .bundle
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
