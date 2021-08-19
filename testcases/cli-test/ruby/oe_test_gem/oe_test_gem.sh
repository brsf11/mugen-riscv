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
# @Date      :   2020/11/20
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of gem command
# ############################################

source "../common/common_ruby.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rubygems
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    gem --help | grep -E "Usage:|gem"
    CHECK_RESULT $?
    gem --version | grep "[0-9]"
    CHECK_RESULT $?
    gem install rake | grep "Successfully installed rake"
    CHECK_RESULT $?
    gem uninstall rake -aIx | grep "Successfully uninstalled rake"
    CHECK_RESULT $?
    gem list --local | grep -E "LOCAL GEMS|[0-9]"
    CHECK_RESULT $?
    gem build example.gemspec | grep -E "Successfully built RubyGem|example-0.1.0.gem"
    CHECK_RESULT $?
    test -f example-0.1.0.gem
    CHECK_RESULT $?
    gem help install | grep "Usage: gem install"
    CHECK_RESULT $?
    gem help build | grep "Usage: gem build"
    CHECK_RESULT $?
    gem help examples | grep "Some examples of 'gem' usage."
    CHECK_RESULT $?
    gem help gem_dependencies | grep "gem"
    CHECK_RESULT $?
    gem help platforms | grep "platforms"
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
