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
# @Author    :   saarloos
# @Contact   :   9090-90-90-9090@163.com
# @Modify    :   9090-90-90-9090@163.com
# @Date      :   2022/04/25
# @License   :   Mulan PSL v2
# @Desc      :   check kernel.randomize_va_space set
#                check fs.suid_dumpable set
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test()
{
    LOG_INFO "Start to run test."

    # check kernel.randomize_va_space set
    getValue=$(sysctl kernel.randomize_va_space | awk -F '=' '{ print $2 }')
    test $getValue -eq 2
    CHECK_RESULT $? 0 0 "check randomize_va_space set value fail"

    # check fs.suid_dumpable set
    getValue=$(sysctl fs.suid_dumpable | awk -F '=' '{ print $2 }')
    test $getValue -eq 0
    CHECK_RESULT $? 0 0 "check fs.suid_dumpable set value fail"

    LOG_INFO "End to run test."
}

main "$@"
