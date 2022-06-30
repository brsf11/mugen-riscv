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
# @Desc      :   verify the uasge of build-jar-repository and rebuild-jar-repository command
# ############################################

source "../common/common_javapackages-tools.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    build-jar-repository -s ./ log4j.jar && test -L '[log4j].jar'
    CHECK_RESULT $?
    build-jar-repository -h ./ junit.jar && test -f '[junit].jar'
    CHECK_RESULT $?
    build-jar-repository -c ./ easymock.jar && test -f '[easymock].jar'
    CHECK_RESULT $?
    build-jar-repository -p ./ qdox.jar && test -f qdox.jar
    CHECK_RESULT $?
    rebuild-jar-repository -c ./ easymock.jar && test -f '[easymock].jar'
    CHECK_RESULT $?
    rebuild-jar-repository -h ./ junit.jar && test -f '[junit].jar'
    CHECK_RESULT $?
    rebuild-jar-repository -s ./ log4j.jar && test -L '[log4j].jar'
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
