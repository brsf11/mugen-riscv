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
    DNF_INSTALL "lxc lxc-devel lxc-libs lxcfs lxcfs-tools tar"
    version=$(rpm -qa lxc | awk -F '-' '{print $2}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    lxc-execute --help 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "Check lxc-execute --help failed."
    lxc-execute --usage 2>&1 | grep -i "Usage: lxc-execute"
    CHECK_RESULT $? 0 0 "Check lxc-execute --usage failed."
    lxc-execute --version | grep $version
    CHECK_RESULT $? 0 0 "Check lxc-execute --version failed."

    lxc-freeze --help 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "Check lxc-freeze --help failed."
    lxc-freeze --usage 2>&1 | grep -i "Usage: lxc-freeze"
    CHECK_RESULT $? 0 0 "Check lxc-freeze --usage failed."
    lxc-freeze --version | grep $version
    CHECK_RESULT $? 0 0 "Check lxc-freeze --version failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the tet environment."
    DNF_REMOVE
    LOG_INFO "End to restore the tet environment."
}

main "$@"
