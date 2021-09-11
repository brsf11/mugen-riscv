#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   yanglijin
# @Contact   :   yang_lijin@qq.com
# @Date      :   2021/09/10
# @License   :   Mulan PSL v2
# @Desc      :   list confined and unconfined user
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL setools-console
    LOG_INFO "End of environmental preparation."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    semanage login -l | grep "__default__" | grep "unconfined_u"
    CHECK_RESULT $? 0 0 "Check user mapping failed"
    seinfo -u | grep -e "guest_u" -e "root" -e "staff_u" -e "sysadm_u" -e "system_u" -e "unconfined_u" -e "user_u" -e "xguest_u"
    CHECK_RESULT $? 0 0 "Check selinux users failed"
    seinfo -r | grep "Roles: 14"
    CHECK_RESULT $? 0 0 "Check selinux roles failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
