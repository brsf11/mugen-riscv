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
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/11/19
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of rake command
# ############################################

source "../common/common_ruby.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rubygem-rake
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rake --help | grep -E "rake|-"
    CHECK_RESULT $?
    rake --version | grep "rake, version.*[0-9]"
    CHECK_RESULT $?
    rake morning:walk_dog --backtrace=stderr | grep "Dog walked."
    CHECK_RESULT $?
    rake -T --comments | grep "morning"
    CHECK_RESULT $?
    rake --job-stats history | grep -E "threads|History|join"
    CHECK_RESULT $?
    rake --rules | grep "Turned off alarm"
    CHECK_RESULT $?
    rake morning:make_coffee --suppress-backtrace --trace | grep "Made 2 cups of coffee"
    CHECK_RESULT $?
    rake -A -T | grep -E "default|morning|root"
    CHECK_RESULT $?
    rake morning:groom_myself -B | grep -E "Brushed teeth|Showered|Shaved"
    CHECK_RESULT $?
    rake -D | grep -E "rake morning|Groom|Make|Ready|Turn|Walk"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    delete_files
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
