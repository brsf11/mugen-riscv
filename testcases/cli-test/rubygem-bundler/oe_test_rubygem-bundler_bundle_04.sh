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
    bundle show | grep "bundler"
    CHECK_RESULT $? 0 0 "Check bundle show failed."
    bundle show -V | grep "Summary"
    CHECK_RESULT $? 0 0 "Check bundle show -V failed."
    bundle show --paths | grep "gems/"
    CHECK_RESULT $? 0 0 "Check bundle show --paths failed."
    bundle update | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update failed."
    bundle update --bundler | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --bundler failed."
    bundle update -r 2
    CHECK_RESULT $? 0 0 "Check bundle update -r failed."
    bundle update -V | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update -V failed."
    bundle update --local | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --local failed."
    bundle update --force | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --force failed."
    bundle check | grep "The Gemfile's dependencies are satisfied"
    CHECK_RESULT $? 0 0 "Check bundle check failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile .bundle
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
