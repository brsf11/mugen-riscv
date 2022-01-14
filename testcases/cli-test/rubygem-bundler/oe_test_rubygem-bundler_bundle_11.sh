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
    bundle config unset --local shebang
    CHECK_RESULT $?
    bundle config --local | grep "shebang"
    CHECK_RESULT $? 1 0 "Check bundle config unset --local failed."
    bundle lock && test -f Gemfile.lock
    CHECK_RESULT $? 0 0 "Check bundle lock failed."
    rm -rf Gemfile.lock
    bundle lock --update && test -f Gemfile.lock
    CHECK_RESULT $? 0 0 "Check bundle lock --update failed."
    rm -rf Gemfile.lock
    bundle lock --local && test -f Gemfile.lock
    CHECK_RESULT $? 0 0 "Check bundle lock --local failed."
    rm -rf Gemfile.lock
    bundle lock --print
    CHECK_RESULT $? 0 0 "Check bundle lock --print failed."
    rm -rf Gemfile.lock
    bundle lock --lockfile && test -f lockfile
    CHECK_RESULT $? 0 0 "Check bundle lock --lockfile failed."
    rm -rf Gemfile.lock
    bundle lock --no-full-index && test -f Gemfile.lock
    CHECK_RESULT $? 0 0 "Check bundle lock --no-full-index failed."
    rm -rf Gemfile.lock
    bundle lock --patch && test -f Gemfile.lock
    CHECK_RESULT $? 0 0 "Check bundle lock --patch failed."
    rm -rf Gemfile.lock
    bundle lock --minor && test -f Gemfile.lock
    CHECK_RESULT $? 0 0 "Check bundle lock --minor failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile Gemfile.lock lockfile .bundle
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
