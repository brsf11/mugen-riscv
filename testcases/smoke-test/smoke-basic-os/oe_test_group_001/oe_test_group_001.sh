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
# @Desc      :   Create User Group test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    grep "testgroup:" /etc/group && groupdel testgroup
    grep "testgroup1:" /etc/group && groupdel testgroup1
    grep "testgroup2:" /etc/group && groupdel testgroup2
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    groupadd testgroup
    CHECK_RESULT $?
    grep testgroup /etc/group
    CHECK_RESULT $?

    groupadd -g 66 testgroup1
    grep testgroup1 /etc/group | grep 66
    CHECK_RESULT $?

    groupadd -g 66 -o testgroup2
    grep testgroup2 /etc/group | grep 66
    CHECK_RESULT $?
    grep testgroup2 /etc/group | grep 66
    CHECK_RESULT $?

    groupadd --help
    CHECK_RESULT $?
    groupdel testgroup
    CHECK_RESULT $?
    groupdel testgroup1
    CHECK_RESULT $?
    groupdel testgroup2
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

main $@
