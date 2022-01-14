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
    bundle info bundler | grep "Summary"
    CHECK_RESULT $? 0 0 "Check bundle info failed."
    bundle info bundler --path | grep "/usr/share/gems/"
    CHECK_RESULT $? 0 0 "Check bundle info bundler --path failed."
    bundle binstubs bundler
    CHECK_RESULT $? 0 0 "Check bundle binstubs failed."
    bundle binstubs bundler --force
    CHECK_RESULT $? 0 0 "Check bundle binstubs --force failed."
    bundle binstubs bundler --path
    CHECK_RESULT $? 0 0 "Check bundle binstubs --path failed."
    bundle binstubs bundler --shebang
    CHECK_RESULT $? 0 0 "Check bundle binstubs --shebang failed."
    bundle binstubs bundler --standalone
    CHECK_RESULT $? 0 0 "Check bundle binstubs --standalone failed."
    bundle exec install --version --no-keep-file-descriptors | grep "install"
    CHECK_RESULT $? 0 0 "Check bundle exec failed."
    bundle open bundler | grep "bundled gem"
    CHECK_RESULT $? 0 0 "Check bundle open failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile .bundle
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
