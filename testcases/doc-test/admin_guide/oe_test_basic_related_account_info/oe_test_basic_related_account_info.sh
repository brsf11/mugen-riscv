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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020.04-09 10:52:41
# @License   :   Mulan PSL v2
# @Desc      :   Documents related to user account information
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase!"
    grep "/bin/bash" /etc/passwd
    CHECK_RESULT $?

    grep "root" /etc/shadow
    CHECK_RESULT $?

    grep "root" /etc/group
    CHECK_RESULT $?

    grep "HOME=/home" /etc/default/useradd
    CHECK_RESULT $?

    grep "PASS_MAX_DAYS" /etc/login.defs
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

main $@
