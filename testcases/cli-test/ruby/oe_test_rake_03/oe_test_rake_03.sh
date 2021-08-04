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
    rake -P | grep -E "rake|*_*"
    CHECK_RESULT $?
    rake -p "puts 'Hello world'" | grep "Hello world"
    CHECK_RESULT $?
    rake morning:walk_dog -q
    CHECK_RESULT $?
    rake -r 'prime' -E 'puts Prime.each(10).to_a.join(", ");' | grep -E '2, 3, 5, 7|Turned off alarm'
    CHECK_RESULT $?
    rake morning:groom_myself -R ./ | grep -E "Brushed|Showered|Shaved"
    CHECK_RESULT $?
    rake -s | grep "Turned off alarm"
    CHECK_RESULT $?
    rake -t morning:make_coffee | grep "Made 2 cups of coffee"
    CHECK_RESULT $?
    rake -T | grep "rake morning"
    CHECK_RESULT $?
    rake -v | grep "Turned off alarm"
    CHECK_RESULT $?
    rake -W | grep -E "rake|rakefile"
    CHECK_RESULT $?
    rake -X | grep "Turned off alarm"
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
