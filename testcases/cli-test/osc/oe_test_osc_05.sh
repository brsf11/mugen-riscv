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
    osc checkout $branches_path | grep 'revision'
    cd $branches_path/zjl || exit 1
    touch {1..3}.txt
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    osc add 1.txt | grep 'A' | grep '1.txt'
    CHECK_RESULT $?
    osc checkin -m "add 1.txt" | grep 'Committed revision'
    CHECK_RESULT $?
    osc delete 1.txt | grep 'D' | grep '1.txt'
    CHECK_RESULT $?
    osc addremove | grep 'A' | grep '2.txt'
    CHECK_RESULT $?
    osc ci -m "delete 1.txt, add 2.txt 3.txt" | grep 'Committed revision'
    CHECK_RESULT $?
    osc mv 2.txt 4.txt | grep 'A' | grep '4.txt'
    CHECK_RESULT $?
    osc ar
    CHECK_RESULT $?
    osc commit -n | grep 'Committed revision'
    CHECK_RESULT $?
    osc lock $branches_path zjl | grep 'Sending'
    CHECK_RESULT $?
    echo 'good boy' >3.txt
    CHECK_RESULT $?
    osc commit -n
    CHECK_RESULT $? 1 0 'Package locked failed'
    osc unlock $branches_path zjl -m "Package unlock"
    CHECK_RESULT $?
    osc commit -n | grep 'Committed revision'
    CHECK_RESULT $?
    osc del 3.txt 4.txt
    osc commit -n
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
