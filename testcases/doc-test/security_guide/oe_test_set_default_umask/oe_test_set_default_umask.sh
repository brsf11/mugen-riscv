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
# @Date      :   2021/03/11
# @License   :   Mulan PSL v2
# @Desc      :   Set the user's default umask value to 022
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    useradd test
    passwd test <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    grep -i "umask 022" /etc/bashrc
    CHECK_RESULT $? 0 0 "umask error"
    mkdir test1
    ls -l . | grep "test1" | grep "drwxr\-xr\-x"
    CHECK_RESULT $? 0 0 "dir permission verification failed"
    touch test2
    ls -l test2 | grep "\-rw\-r\-\-r\-\-"
    CHECK_RESULT $? 0 0 "file permission verification failed"
    su - test -c "mkdir test3"
    su - test -c "ls -l | grep "test3" | grep 'drwxr\-xr\-x'"
    CHECK_RESULT $? 0 0 "dir permission verification failed"
    su - test -c "touch test4"
    su - test -c "ls -l test4 | grep '\-rw\-r\-\-r\-\-'"
    CHECK_RESULT $? 0 0 "file permission verification failed"
    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rf test
    rm -rf test1 test2
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
