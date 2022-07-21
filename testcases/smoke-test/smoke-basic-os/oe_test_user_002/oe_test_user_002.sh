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
# @Desc      :   test -g -s -m and delete user
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    grep "testuser1:" /etc/passwd && userdel -rf testuser1
    grep "test:" /etc/group && groupdel test
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    groupadd test
    gid=$(grep "test:" /etc/group | awk -F':' '{print $3}')
    useradd -g "${gid}" -s /sbin/nologin -m testuser1
    CHECK_RESULT $?
    su testuser1 | grep 'account is currently not available'
    CHECK_RESULT $?
    test $(grep testuser1 /etc/passwd | awk -F ':' '{print $4}') -eq "${gid}"
    CHECK_RESULT $?
    test -d /home/testuser1
    CHECK_RESULT $?
    userdel -rf testuser1
    CHECK_RESULT $?
    test -d /home/testuser1
    CHECK_RESULT $? 1
    grep testuser1 /etc/passwd
    CHECK_RESULT $? 1
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    groupdel test
    export LANG=${OLD_LANG}
    LOG_INFO "Finish environment cleanup!"
}

main $@
