#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-11-2
#@License       :   Mulan PSL v2
#@Desc          :   OSC is a command line tool based on OBS, which is equivalent to the interface of OBS.
#####################################

source "common/common_osc.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    deploy_env
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL osc
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    osc --help | grep 'Usage'
    CHECK_RESULT $?
    osc --version | grep [0-9]
    CHECK_RESULT $?
    osc man | grep 'man page'
    CHECK_RESULT $?
    osc list | grep 'openEuler'
    CHECK_RESULT $?
    osc api http://117.78.1.88 | grep 'Open Build Service API'
    CHECK_RESULT $?
    osc checkout $branches_path | grep 'revision'
    CHECK_RESULT $?
    osc cat $branches_path/zjl/last_file.txt | grep 'momohao'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
