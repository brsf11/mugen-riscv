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
# @Desc      :   Test sleep.target restart
# #############################################

source "../common/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    LOG_INFO "A special target unit that is pulled in by suspend.target, hibernate.target and hybrid-sleep.target and may be used to hook units into the sleep state logic."
    test_oneshot sleep.target 'inactive (dead)'
    LOG_INFO "End of the test."
}

main "$@"
