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
# @Desc      :   Test suspend-then-hibernate.target restart
# #############################################

source "../common/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    LOG_INFO "A special target unit for suspending the system for a period of time, waking it and putting it into hibernate. This pulls in sleep.target."
    test_oneshot suspend-then-hibernate.target 'inactive (dead)'
    LOG_INFO "End of the test."
}

main "$@"
