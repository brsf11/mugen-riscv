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
    cd $branches_path || exit 1
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    osc mkpac xzz | grep 'xzz'
    CHECK_RESULT $?
    osc commit -m "create new package" | grep 'Sending'
    CHECK_RESULT $?
    osc rdelete $branches_path xzz -m "delete package"
    CHECK_RESULT $?
    osc update | grep "Updating"
    CHECK_RESULT $?
    osc undelete $branches_path xzz -m "restore deletion package"
    CHECK_RESULT $?
    osc up | grep "Updating"
    CHECK_RESULT $?
    osc meta prj $branches_path | grep 'project name'
    CHECK_RESULT $?
    osc my prj -m | grep "$branches_path"
    CHECK_RESULT $?
    nohup osc patchinfo >osc_patchinfo.log 2>&1 &
    SLEEP_WAIT 3 "grep 'patchinfo' osc_patchinfo.log" 2
    CHECK_RESULT $?
    osc rdelete $branches_path patchinfo -m "delete package_patchinfo"
    osc rdelete $branches_path xzz -m "delete package_xzz"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
