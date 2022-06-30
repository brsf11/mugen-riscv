#!/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   zhangpanting
# @Contact   :   1768492250@qq.com
# @Date      :   2020-05-05
# @License   :   Mulan PSL v2
# @Desc      :   verification lxc‘s info command
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "lxc lxc-devel lxc-libs lxcfs lxcfs-tools tar busybox"
    version=$(rpm -qa lxc | awk -F '-' '{print $2}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    lxc-create -t /usr/share/lxc/templates/lxc-busybox -n myEuler1
    CHECK_RESULT $? 0 0 "Failed to set up container."
    lxc-start myEuler1
    CHECK_RESULT $? 0 0 "Failed to start container."
    
    lxc-info --help 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "Check lxc-info --help failed."
    lxc-info --usage 2>&1 | grep -i "Usage: lxc-info"
    CHECK_RESULT $? 0 0 "Check lxc-info --usage failed."
    lxc-info --version | grep $version
    CHECK_RESULT $? 0 0 "Check lxc-info --version failed."

    lxc-info myEuler1 | grep -i "State" | grep -i "RUNNING" 
    CHECK_RESULT $? 0 0 "Check lxc-info failed."
    lxc-info -n myEuler1 | grep -i "CPU use:" | grep -i "seconds" 
    CHECK_RESULT $? 0 0 "Check lxc-info -n failed."
    lxc-info -p myEuler1 | grep -i "PID:"
    CHECK_RESULT $? 0 0 "Check lxc-info -p failed."
    lxc-info -S myEuler1 | grep -i "Memory use:"
    CHECK_RESULT $? 0 0 "Check lxc-info -S failed."
    lxc-info -s myEuler1 | grep -i "RUNNING"
    CHECK_RESULT $? 0 0 "Check lxc-info -s failed."
    lxc-info -H myEuler1  | grep -i "BlkIO use:"
    CHECK_RESULT $? 0 0 "Check lxc-info -H failed."
    
    lxc-stop myEuler1
    lxc-info -s myEuler1 | grep -i "STOPPED"
    CHECK_RESULT $? 0 0 "Check lxc-info -s failed."
    lxc-info -n myEuler1 | grep -i "State" | grep -i "STOPPED"
    CHECK_RESULT $? 0 0 "Check lxc-info -n failed."  
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the tet environment."
    lxc-destroy myEuler1
    DNF_REMOVE
    LOG_INFO "End to restore the tet environment."
}

main "$@"
