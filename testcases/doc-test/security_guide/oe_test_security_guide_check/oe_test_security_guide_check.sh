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
# @Date      :   2022-08-30
# @License   :   Mulan PSL v2
# @Desc      :   check_passwd_encryption_algorithm
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "create test user"
    useradd test
    echo "openeuler12#$" | passwd --stdin test
}

function run_test() {
    grep 'test' /etc/shadow | grep $6$
    CHECK_RESULT $? 0 0 "exec 'test_sha512' failed"
    grep 'root' /etc/shadow | grep $6$
    CHECK_RESULT $? 0 0 "exec 'root_sha512' failed"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rf test
}
main "$@"