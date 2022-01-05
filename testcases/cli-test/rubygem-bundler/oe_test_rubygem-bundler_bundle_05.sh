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

    bundle check --dry-run | grep "The Gemfile's dependencies are satisfied"
    CHECK_RESULT $? 0 0 "Check bundle check --dry-run failed."
    bundle check --gemfile Gemfile | grep "The Gemfile's dependencies are satisfied"
    CHECK_RESULT $? 0 0 "Check bundle check --gemfile failed."
    bundle check --path /opt | grep "The Gemfile's dependencies are satisfied"
    CHECK_RESULT $? 0 0 "Check bundle check --path failed."
    expect <<-END
    spawn bundle console
    expect "irb(main):001:0"
    send "exit\n"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check bundle console failed."
    expect <<-END
    spawn bundle console -r 2
    expect "irb(main):001:0"
    send "exit\n"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check bundle console -r failed."
    expect <<-END
    spawn bundle console -V
    expect "irb(main):001:0"
    send "exit\n"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check bundle console -V failed."
    bundle console -h | grep "bundle console"
    CHECK_RESULT $? 0 0 "Check bundle console -h failed."
    bundle env | grep "Environment"
    CHECK_RESULT $? 0 0 "Check bundle env failed."
    bundle env -r 2
    CHECK_RESULT $? 0 0 "Check bundle -r  failed."
    bundle env -V
    CHECK_RESULT $? 0 0 "Check bundle -V failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile .bundle
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
