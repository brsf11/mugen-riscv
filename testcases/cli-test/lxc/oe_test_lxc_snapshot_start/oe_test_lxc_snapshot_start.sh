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
    lxc-start --help 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "Check lxc-start --help failed."
    lxc-start --usage 2>&1 | grep -i "Usage: lxc-start"
    CHECK_RESULT $? 0 0 "Check lxc-start --usage failed."
    lxc-start --version | grep $version
    CHECK_RESULT $? 0 0 "Check lxc-start --version failed."
    lxc-start -n myEuler1 -d
    CHECK_RESULT $? 0 0 "Check lxc-start -n failed."
    lxc-info myEuler1 | grep State | grep RUNNING
    CHECK_RESULT $? 0 0 "Check lxc-info failed."

    lxc-snapshot --help 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "Check lxc-snapshot --help failed."
    lxc-snapshot --usage 2>&1 |  grep -i "Usage: lxc-snapshot"
    CHECK_RESULT $? 0 0 "Check lxc-snapshot --usage failed."
    lxc-snapshot --version | grep $version
    CHECK_RESULT $? 0 0 "Check lxc-snapshot --version failed."
    lxc-snapshot -L myEuler1
    CHECK_RESULT $? 0 0 "Check lxc-snapshot -L failed."
    lxc-stop -n myEuler1
    CHECK_RESULT $? 0 0 "Check lxc-stop -n failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the tet environment."
    lxc-stop myEuler1
    lxc-destroy myEuler1
    DNF_REMOVE
    LOG_INFO "End to restore the tet environment."
}

main "$@"
