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
    bundle install --system | grep "Bundle complete"
    CHECK_RESULT $? 0 0 "Check bundle install --system failed."
    bundle install --shebang jruby
    CHECK_RESULT $? 0 0 "Check bundle install --shebang failed."
    bundle install --trust-policy HighSecurity | grep "Bundle complete!"
    CHECK_RESULT $? 0 0 "Check bundle install --trust-policy failed."
    bundle config list | grep "Settings are listed"
    CHECK_RESULT $? 0 0 "Check bundle config list failed."
    bundle config get path | grep "value will be used"
    CHECK_RESULT $? 0 0 "Check bundle config get path failed."
    bundle config set shebang test && bundle config | grep "test"
    CHECK_RESULT $? 0 0 "Check bundle config set failed."
    bundle config unset shebang && bundle config | grep "shebang"
    CHECK_RESULT $? 1 0 "Check bundle config unset failed."
    bundle config set --global shebang test && bundle config | grep "shebang"
    CHECK_RESULT $? 0 0 "Check bundle config set --global failed."
    bundle config unset --global shebang && bundle config | grep "shebang"
    CHECK_RESULT $? 1 0 "Check bundle config unset --global failed."
    bundle config set --local shebang test && bundle config --local | grep "shebang"
    CHECK_RESULT $? 0 0 "Check bundle config set --local failed."
    bundle config unset --local shebang
    CHECK_RESULT $?
    bundle config --local | grep "shebang"
    CHECK_RESULT $? 1 0 "Check bundle config unset --local failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile .bundle
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
