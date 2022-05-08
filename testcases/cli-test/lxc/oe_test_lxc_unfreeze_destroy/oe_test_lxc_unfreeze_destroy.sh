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
# @Author    :   wanxiaofei_wx5323714
# @Contact   :   wanxiaofei4@huawei.com
# @Date      :   2020-08-02
# @License   :   Mulan PSL v2
# @Desc      :   verification lxc‘s attach command
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
    lxc-unfreeze --help 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "Check lxc-unfreeze --help failed."
    lxc-unfreeze --usage 2>&1 |  grep -i "Usage: lxc-unfreeze"
    CHECK_RESULT $? 0 0 "Check lxc-unfreeze --usage failed."
    lxc-unfreeze --version | grep $version
    CHECK_RESULT $? 0 0 "Check lxc-unfreeze --version failed."
    lxc-freeze myEuler1
    CHECK_RESULT $? 0 0 "Check lxc-freeze failed."
    lxc-info myEuler1 | grep State | grep FROZEN
    CHECK_RESULT $? 0 0 "Check lxc-info failed."
    lxc-unfreeze -n myEuler1
    CHECK_RESULT $? 0 0 "Check lxc-unfreeze failed."
    lxc-info myEuler1 | grep State | grep RUNNING
    CHECK_RESULT $? 0 0 "Check lxc-info failed."

    lxc-destroy --help 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "Check lxc-destroy --help failed."
    lxc-destroy --usage 2>&1 |  grep -i "Usage: lxc-destroy"
    CHECK_RESULT $? 0 0 "Check lxc-destroy --usage failed."
    lxc-destroy --version | grep $version
    CHECK_RESULT $? 0 0 "Check lxc-destroy --version failed."
    lxc-stop myEuler1
    CHECK_RESULT $? 0 0 "Check lxc-stop failed."
    lxc-destroy -n myEuler1
    CHECK_RESULT $? 0 0 "Check lxc-destroy -n failed."
    lxc-ls | grep myEuler1
    CHECK_RESULT $? 1 0 "Check lxc-ls failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the tet environment."
    DNF_REMOVE
    LOG_INFO "End to restore the tet environment."
}

main "$@"
