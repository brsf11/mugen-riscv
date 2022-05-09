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
# @Desc      :   check hello message
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test()
{
    LOG_INFO "Start to run test."

    egrep -v '^\s*#|^\s*$' /etc/motd 2>/dev/null
    CHECK_RESULT $? 0 0 "not set /etc/motd hello message"

    egrep -v '^\s*#|^\s*$' /etc/issue 2>/dev/null
    CHECK_RESULT $? 0 0 "not set /etc/issue hello message"
    
    egrep -v '^\s*#|^\s*$' /etc/issue.net 2>/dev/null
    CHECK_RESULT $? 0 0 "not set /etc/issue.net hello message"

    grep -i "^Banner" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "not set /etc/ssh/sshd_config hello message"
    
    LOG_INFO "End to run test."
}

main "$@"
