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
# @Desc      :   restrict accounts use su
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    grep "^test1:" /etc/passwd && userdel -rf test1
    grep "^test2:" /etc/passwd && userdel -rf test2
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    grep 'pam_wheel.so' /etc/pam.d/su | grep 'required'
    CHECK_RESULT $? 0 0 "check /etc/pam.d/su failed"
    useradd test1
    passwd test1 <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    useradd test2
    passwd test2 <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    usermod -aG wheel test2
    groups test2 | grep 'wheel'
    CHECK_RESULT $? 0 0 "add test2 to group wheel failed"
    su - test1 -c "su" <<EOF
${NODE1_PASSWORD}
EOF
    CHECK_RESULT $? 0 1 "check su test1 failed"
    su - test2 -c "su" <<EOF
${NODE1_PASSWORD}
EOF
    CHECK_RESULT $? 0 0 "check su test2 failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rf test1
    userdel -rf test2
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
