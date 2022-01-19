#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##############################################
# @Author    :   suhang
# @Contact   :   suhangself@163.com
# @Date      :   2022-01-05
# @License   :   Mulan PSL v2
# @Desc      :   System Management Tools auter
# ##############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL auter
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    auter -h | grep "Usage"
    CHECK_RESULT $? 0 0 "Help information printing failed"
    auter -v | grep "[0-9]"
    CHECK_RESULT $? 0 0 "Version information printing failed"
    auter --status | grep "enabled"
    CHECK_RESULT $? 0 0 "Failed to check the status"
    auter --disable | grep "disabled"
    auter --status | grep "disabled"
    CHECK_RESULT $? 0 0 "Disable the failure"
    auter --enable | grep "enabled"
    CHECK_RESULT $? 0 0 "Enable the failure"
    auter --prep | grep "downloaded"
    CHECK_RESULT $? 0 0 "Predownload failed"
    auter --apply | grep "successfully"
    CHECK_RESULT $? 0 0 "Application of failure"
    auter --postreboot | grep "post-reboot"
    CHECK_RESULT $? 0 0 "Postreboot of failure"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
