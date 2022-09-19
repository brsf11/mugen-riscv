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
# @Author    :   wulei
# @Contact   :   wulei@uniontech.com
# @Date      :   2022-09-19
# @License   :   Mulan PSL v2
# @Desc      :   whoami command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "env configure"
    useradd tester
    echo "openeuler12#$" | passwd --stdin tester
}

function run_test() {
    whoami | grep root
    CHECK_RESULT $? 0 0 "exec 'check user' failed"
    su -c whoami tester | grep tester
    CHECK_RESULT $? 0 0 "exec 'check user' failed"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rf tester
}
main "$@"