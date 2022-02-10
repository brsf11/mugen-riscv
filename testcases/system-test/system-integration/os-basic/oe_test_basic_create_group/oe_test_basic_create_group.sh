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
# @Desc      :   Create User Group test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase!"
    grep -w testgroup /etc/group && groupdel testgroup
    groupadd testgroup
    CHECK_RESULT $?
    grep -w testgroup /etc/group
    CHECK_RESULT $?

    grep -w testgroup1 /etc/group && groupdel testgroup1
    groupadd -g 6666 testgroup1
    CHECK_RESULT $?
    grep -w testgroup1 /etc/group | grep 6666
    CHECK_RESULT $?

    grep -w testgroup2 /etc/group && groupdel testgroup2
    groupadd -g 9999 -o testgroup2
    CHECK_RESULT $?
    grep -w testgroup2 /etc/group | grep 9999
    CHECK_RESULT $?

    groupadd --help | grep 'Usage: groupadd'
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    groupdel testgroup
    groupdel testgroup1
    groupdel testgroup2
    LOG_INFO "Finish environment cleanup."
}

main $@
