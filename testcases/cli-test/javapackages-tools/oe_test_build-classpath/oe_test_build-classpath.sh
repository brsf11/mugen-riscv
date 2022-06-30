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
# @Date      :   2020/10/26
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of build-classpath and build-classpath-directory command
# ############################################

source "../common/common_javapackages-tools.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    build-classpath log4j | grep -E "/usr/share/java/log4j.jar"
    CHECK_RESULT $?
    build-classpath junit | grep -E "/usr/share/java/junit.jar"
    CHECK_RESULT $?
    build-classpath easymock beust-jcommander | grep -E "/usr/share/java/easymock.jar|/usr/share/java/beust-jcommander.jar"
    CHECK_RESULT $?
    build-classpath-directory --help | grep "Usage:"
    CHECK_RESULT $?
    build-classpath-directory --version | grep "[0-9]"
    CHECK_RESULT $?
    build-classpath-directory /usr/share/java | tr ':' '\n' | grep "/usr/share/java"
    CHECK_RESULT $?
    build-classpath-directory /usr/lib | tr ':' '\n' | grep "/usr/lib"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
