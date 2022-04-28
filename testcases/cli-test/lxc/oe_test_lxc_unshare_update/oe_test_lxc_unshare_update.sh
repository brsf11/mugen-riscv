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
    lxc-unshare --help 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "Check lxc-unshare --help failed."
    lxc-unshare --usage 2>&1 | grep -i "Usage: lxc-unshare"
    CHECK_RESULT $? 0 0 "Check lxc-unshare --usage failed."
    lxc-unshare --version | grep $version
    CHECK_RESULT $? 0 0 "Check lxc-unshare --version failed."

    lxc-update-config --help | grep config
    CHECK_RESULT $? 0 0 "Check lxc-update-config --help failed."
    echo 'hello' >testlog
    lxc-update-config -c testlog && test -f testlog.backup
    CHECK_RESULT $? 0 0 "Check lxc-update-config -c failed."

    lxc-wait --help 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "Check lxc-wait --help failed."
    lxc-wait --usage 2>&1 | grep -i "Usage: lxc-wait"
    CHECK_RESULT $? 0 0 "Check lxc-wait --usage failed."
    lxc-wait --version | grep $version
    CHECK_RESULT $? 0 0 "Check lxc-wait --version failed."
    lxc-wait -n myEuler1 -s RUNNING &
    CHECK_RESULT $? 0 0 "Check lxc-wait -n failed."
    lxc-start myEuler1
    SLEEP_WAIT 2
    ps -ef | grep lxc-wait | grep -v grep
    CHECK_RESULT $? 1 0 "Check lxc-wait process failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the tet environment."
    rm -rf testlog*
    lxc-stop myEuler1
    lxc-destroy myEuler1
    DNF_REMOVE
    LOG_INFO "End to restore the tet environment."
}

main "$@"
