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
# @Desc      :   check SSH Client Alive set
#                check SSH MaxStartups and LoginGraceTime
#                check SSH MaxStartups and LoginGraceTime
#                check known_hosts and authorized_keys permission
#                check SSH Banner set
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test()
{
    LOG_INFO "Start to run test."

    # check SSH Client Alive set
    grep "^\s*ClientAliveInterval 300" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "check SSH ClientAliveInterval set"

    grep "^\s*ClientAliveCountMax 0" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "check SSH ClientAliveCountMax set"

    # check SSH MaxStartups and LoginGraceTime
    grep "^\s*MaxStartups" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "check SSH MaxStartups set"

    grep "^\s*LoginGraceTime" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "check SSH LoginGraceTime set"

    getNum=$(cat /etc/ssh/sshd_config | grep "^\s*LoginGraceTime" | awk '{print $2}')
    test $getNum -eq 0
    CHECK_RESULT $? 0 1 "LoginGraceTime set time is 0"

    # check UsePAM
    cat /etc/ssh/sshd_config | grep "^\s*UsePAM" | grep "yes"
    CHECK_RESULT $? 0 0 "check SSH UsePAM set fail"

    # check known_hosts and authorized_keys permission
    getNum=$(find /root/.ssh/known_hosts -maxdepth 0 \( ! -user root  -o  ! -group root  -o  -perm /177 \) 2>/dev/null | wc -l)
    test $getNum -eq 0
    CHECK_RESULT $? 0 0 "check /root/.ssh/known_hosts files permission fail"

    getNum=$(find /root/.ssh/authorized_keys -maxdepth 0 \( ! -user root  -o  ! -group root  -o  -perm /177 \) 2>/dev/null | wc -l)
    test $getNum -eq 0
    CHECK_RESULT $? 0 0 "check /root/.ssh/authorized_keys files permission fail"

    # check SSH Banner set
    grep "^\s*Banner /etc/issue.net" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "check SSH Banner set fail"

    LOG_INFO "End to run test."
}

main "$@"
