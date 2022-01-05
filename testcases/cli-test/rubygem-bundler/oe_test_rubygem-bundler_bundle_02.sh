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
    bundle gem testgem01 --coc | grep "CODE_OF_CONDUCT.md"
    CHECK_RESULT $? 0 0 "Check gem testgem --coc failed."
    bundle gem testgem02 --ext | grep "ext"
    CHECK_RESULT $? 0 0 "Check gem testgem --ext failed."
    bundle gem testgem03 --no-ext | grep "ext"
    CHECK_RESULT $? 1 0 "Check gem testgem --no-ext failed."
    bundle gem testgem04 --mit | grep "LICENSE.txt"
    CHECK_RESULT $? 0 0 "Check gem testgem --mit failed."
    bundle gem testgem05 --no-mit | grep "LICENSE.txt"
    CHECK_RESULT $? 1 0 "Check gem testgem --no-mit failed."
    bundle gem testgem06 --ci travis | grep "travis.yml"
    CHECK_RESULT $? 0 0 "Check gem testgem --ci failed."
    bundle update --all | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --all failed."
    bundle update --group development | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --group failed."
    bundle update --source rails | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --source failed."
    bundle update --ruby | grep "Bundle updated!"
    CHECK_RESULT $? 0 0 "Check bundle update --ruby failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile testgem* .bundle
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
