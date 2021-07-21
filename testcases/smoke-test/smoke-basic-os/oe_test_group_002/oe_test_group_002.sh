#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Modity User Group test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    grep "testuser1:" /etc/passwd && userdel -rf testuser1
    useradd testuser1
    grep "testgroup1:" /etc/group && groupdel testgroup1
    grep "testgroup2:" /etc/group && groupdel testgroup2
    groupadd testgroup1
    groupmod -g 66 testgroup1
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    groupmod -g 88 testgroup1
    CHECK_RESULT $?
    grep testgroup1 /etc/group | grep 88
    CHECK_RESULT $?

    groupmod -n testgroup2 testgroup1
    CHECK_RESULT $?
    grep testgroup2 /etc/group | grep 88
    CHECK_RESULT $?

    grep testgroup1 /etc/group
    CHECK_RESULT $? 1

    usermod -a -G testgroup2 testuser1
    CHECK_RESULT $?
    grep testgroup2 /etc/group | grep testuser1
    CHECK_RESULT $?

    groupmod --help
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    groupdel testgroup2
    userdel -rf testuser1
    LOG_INFO "Finish environment cleanup!"
}

main $@
