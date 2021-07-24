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
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    nohup osc log >osc.log 2>&1 &
    SLEEP_WAIT 3 "grep 'add 1.txt' osc.log" 2
    CHECK_RESULT $?
    osc info | grep 'Project name'
    CHECK_RESULT $?
    osc config section --dump-full | grep 'passx'
    CHECK_RESULT $?
    osc config section --dump | grep 'plaintext_passwd'
    CHECK_RESULT $?
    osc clean . | grep 'Removing: osc.log'
    CHECK_RESULT $?
    osc comment list package $branches_path zjl
    CHECK_RESULT $?
    touch 4.txt
    osc add * | grep 'A' | grep '4.txt'
    CHECK_RESULT $?
    osc commit -n | grep 'Committed revision'
    CHECK_RESULT $?
    echo "good girl" >4.txt
    CHECK_RESULT $?
    nohup osc diff >osc_diff.log 2>&1 &
    SLEEP_WAIT 3 "grep 'good girl' osc_diff.log" 2
    CHECK_RESULT $?
    osc add * | grep 'A' | grep 'osc_diff.log'
    CHECK_RESULT $?
    osc commit -n | grep 'Committed revision'
    CHECK_RESULT $?
    osc diff
    CHECK_RESULT $?
    expect <<-END
        spawn osc rremove $branches_path zjl 4.txt
        expect "function/zjl"
        send "y\\n"
        expect eof
        exit
END
    CHECK_RESULT $?
    expect <<-END
        spawn osc rremove $branches_path zjl osc_diff.log
        expect "function/zjl"
        send "y\\n"
        expect eof
        exit
END
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
