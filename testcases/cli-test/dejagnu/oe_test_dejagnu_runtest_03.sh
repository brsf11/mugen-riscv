#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   zhoulimin
# @Contact   :   limin@isrc.iscas.ac.cn 
# @Date      :   2022-09-07
# @License   :   Mulan PSL v2
# @Desc      :   The test of dejagnu package 
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"


function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL dejagnu
    test -d tmp || mkdir tmp
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    runtest CALC=common/calc -v --build=$(uname -i)-pc-linux-gnu --srcdir common --outdir tmp 2>&1 | grep "Native configuration is $(uname -i)-pc-linux-gnu"
    CHECK_RESULT $? 0 0 "Failed option : --build"
    runtest CALC=common/calc -v --target='aarch64-pc-linux-gnu' --srcdir common --outdir tmp 2>&1 | grep "Target is aarch64-pc-linux-gnu"
    CHECK_RESULT $? 0 0 "Failed option : --target"
    runtest CALC=common/calc -v --host=$(uname -i)-pc-linux-gnu --srcdir common --outdir tmp 2>&1 | grep "Native configuration is $(uname -i)-pc-linux-gnu"
    CHECK_RESULT $? 0 0 "Failed option : --host"
    rm -rf tmp/*
    runtest CALC=common/calc -v --status --srcdir common --outdir tmp 
    test -f ./tmp/*.log
    CHECK_RESULT $? 0 0 "Failed option : --status"
    runtest CALC=common/calc -v --tool_exec=common/calc.test/calc.exp --srcdir common --outdir tmp 2>&1 | grep "Running only tests --tool_exec=common/calc.test/calc.exp" 
    CHECK_RESULT $? 0 0 "Failed option : --tool_exec"
    runtest CALC=common/calc -v --tool_opts=common/calc.test/calc.exp --srcdir common --outdir tmp 2>&1 | grep "Running only tests --tool_opts=common/calc.test/calc.exp"
    CHECK_RESULT $? 0 0 "Failed option : --tool_opts"
    runtest CALC=common/calc -v --host_board=common/calc -v --srcdir common --outdir tmp 2>&1 | grep "Verbose level is [[:digit:]]"
    CHECK_RESULT $? 0 0 "Failed option : --host_board"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf tmp *.sum *.log
    LOG_INFO "Finish environment cleanup!"
}

main "$@"