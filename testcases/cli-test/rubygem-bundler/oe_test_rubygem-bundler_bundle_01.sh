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
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    bundle init | grep "Gemfile"
    CHECK_RESULT $? 0 0 "Check bundle init failed."
    rm -rf Gemfile
    bundle init -r 2 | grep "Gemfile"
    CHECK_RESULT $? 0 0 "Check bundle init -r 2 failed."
    rm -rf Gemfile
    bundle init -V | grep "with bundler"
    CHECK_RESULT $? 0 0 "Check bundle init -V failed."
    rm -rf Gemfile
    expect <<-END
    spawn bundle gem testgem01
    expect "This means that.*"
    send "Y\n"
	expect "MIT License enabled.*"
    send "Y\n"
	expect "A changelog is a file.*"
    send "Y\n"
	expect "Enter a linter.*"
    send "Y\n"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check bundle gem failed."
    expect <<-END
    spawn bundle gem testgem02 -t
    expect "Enter a test framework.*"
    send "Y\n"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check bundle gem testgem -t failed."
    expect <<-END
    spawn bundle gem testgem03 -e
    expect "A changelog is a file.*"
    send "Y\n"
	expect "RuboCop is a static code.*"
    send "Y\n"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check gem testgem -e failed."
    bundle gem testgem03 -V | grep "Creating gem"
    CHECK_RESULT $? 0 0 "Check gem testgem -V failed."
    bundle gem testgem04 --exe | grep "exe"
    CHECK_RESULT $? 0 0 "Check gem testgem --exe failed."
    bundle gem testgem05 --no-exe | grep "exe"
    CHECK_RESULT $? 1 0 "Check gem testgem --no-exe failed."
    bundle gem testgem06 --no-coc | grep "CODE_OF_CONDUCT.md"
    CHECK_RESULT $? 1 0 "Check gem testgem --no-coc failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile testgem*  ~/.bundle
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
