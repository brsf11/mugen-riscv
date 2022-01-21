#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2020/12/29
# @License   :   Mulan PSL v2
# @Desc      :   Test time-set.target restart
# #############################################

source "../common/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    CHECK_RESULT $? 0 0 "There is an error for the status of time-set.target"
    systemctl restart time-set.target 2>&1 | grep "it is configured to refuse manual start/stop"
    CHECK_RESULT $? 0 0 "Check time-set.target failed"
    systemctl stop time-set.target
    CHECK_RESULT $? 0 0 "time-set.target stop failed"
    systemctl start time-set.target 2>&1 | grep "it is configured to refuse manual start/stop"
    CHECK_RESULT $? 0 0 "Check time-set.target failed"
    test_enabled time-set.target
    LOG_INFO "End of the test."
}

main "$@"
