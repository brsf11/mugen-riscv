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
    user_name=$(cat /root/.oscrc | grep user | awk -F '=' '{print $NF}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    osc mkpac xzz | grep 'xzz'
    osc commit -m "create new package" | grep 'Sending'
    osc token
    CHECK_RESULT $?
    osc whois | grep "$user_name"
    CHECK_RESULT $?
    osc copypac openEuler:Mainline glibc $branches_path glibc | grep 'comment'
    CHECK_RESULT $?
    osc up | grep 'checking out new package'
    CHECK_RESULT $?
    osc aggregatepac openEuler:Mainline chrpath $branches_path xzz | grep 'Creating _aggregate'
    CHECK_RESULT $?
    osc up | grep "Updating"
    CHECK_RESULT $?
    osc linkpac openEuler:Mainline chrpath $branches_path xzz | grep 'Creating _link'
    CHECK_RESULT $?
    osc up | grep "Updating"
    CHECK_RESULT $?
    cd xzz || exit 1
    if [ "$FRAME" = "aarch64" ]; then
        osc buildinfo | grep 'buildinfo'
        CHECK_RESULT $?
    fi
    osc linktobranch | grep 'revision'
    CHECK_RESULT $?
    osc pdiff
    CHECK_RESULT $?
    cd .. || exit 1
    osc rdelete $branches_path glibc -m "delete package_glibc"
    osc rdelete $branches_path xzz -m "delete package_xzz"
    osc commit -n
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
