#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ####################################S#########
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @modify    :   wangxiaoya@qq.com
# @Date      :   2022/05/12
# @License   :   Mulan PSL v2
# @Desc      :   sestatus view selinux status strategy
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    sestatus | grep "SELinux status" | grep "enabled"
    CHECK_RESULT $?
    sestatus | grep "SELinuxfs mount" | grep "/sys/fs/selinux"
    CHECK_RESULT $?
    sestatus | grep "SELinux root directory" | grep "/etc/selinux"
    CHECK_RESULT $?
    sestatus | grep "Loaded policy name" | grep "targeted"
    CHECK_RESULT $?
    sestatus | grep "Current mode" | grep "enforcing"
    CHECK_RESULT $?
    sestatus | grep "Mode from config file" | grep "enforcing"
    CHECK_RESULT $?
    sestatus | grep "Policy MLS status" | grep "enabled"
    CHECK_RESULT $?
    sestatus | grep "Policy deny_unknown status" | grep "allowed"
    CHECK_RESULT $?
    sestatus | grep "Memory protection checking" | grep "actual"
    CHECK_RESULT $?
    sestatus | grep "Max kernel policy version"
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}
main "$@"
