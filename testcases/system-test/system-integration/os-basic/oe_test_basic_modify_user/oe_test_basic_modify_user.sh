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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Modify User test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    grep -w testuser1 /etc/passwd && userdel testuser1
    grep -w testgroup1 /etc/group && groupdel testgroup1
    useradd -u 555 testuser
    groupmod -g 555 testuser
    groupadd -g 72 testgroup1
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    usermod -u 666 testuser
    grep -w testuser /etc/passwd | awk -F : '{print$3}' | grep 666
    CHECK_RESULT $?
    usermod -g 72 testuser
    CHECK_RESULT $?
    grep testuser /etc/passwd | awk -F : '{print$4}' | grep 72
    CHECK_RESULT $?
    usermod --help | grep Usage
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -r testuser
    groupdel testgroup1
    LOG_INFO "Finish environment cleanup."
}

main $@
