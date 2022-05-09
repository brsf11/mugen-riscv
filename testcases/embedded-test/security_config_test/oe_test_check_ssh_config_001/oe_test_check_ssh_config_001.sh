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
# @Desc      :   check SSL version
#                check SyslogFacility and LogLevel
#                check X11Forwarding
#                check MaxAuthTries set
#                check IgnoreRhosts
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test()
{
    LOG_INFO "Start to run test."

    # check SSL version
    grep "Protocol 2" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "check SSL version fail"

    # check SyslogFacility and LogLevel
    grep "^\s*SyslogFacility AUTH" /etc/ssh/sshd_config 
    CHECK_RESULT $? 0 0 "check SSH SyslogFacility fail"

    cat /etc/ssh/sshd_config | grep "^\s*LogLevel" | grep "DEBUG"
    CHECK_RESULT $? 0 1 "check SSH SyslogFacility fail"

    # check X11Forwarding
    grep "^\s*X11Forwarding no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "check SSH X11Forwarding set fail"

    # check MaxAuthTries set
    grep "^\s*MaxAuthTries" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "check SSH MaxAuthTries set fail"

    getValue=$(cat /etc/ssh/sshd_config | grep "^\s*MaxAuthTries" | awk '{print $2}')
    test $getValue -eq 3
    CHECK_RESULT $? 0 0 "check SSH MaxAuthTries set number fail"

    # check IgnoreRhosts
    grep "^\s*IgnoreRhosts yes" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "check SSH IgnoreRhosts set fail"

    LOG_INFO "End to run test."
}

main "$@"
