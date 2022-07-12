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
# @Author    :   wangxiaoya
# @Contact   :   wangxiaoya@qq.com
# @Date      :   2022/5/30
# @License   :   Mulan PSL v2
# @Desc      :   SSH strong encryption algorithm - enable hardening by default
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    grep "^Ciphers" /etc/ssh/sshd_config | grep ctr
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^MACs" /etc/ssh/sshd_config | grep sha2
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^Ciphers" /etc/ssh/sshd_config | grep cbc
    CHECK_RESULT $? 0 1 "Security reinforcement options are set."
    grep "^MACs" /etc/ssh/sshd_config | grep sha1
    CHECK_RESULT $? 0 1 "Security reinforcement options are set."
    grep "^MACs" /etc/ssh/sshd_config | grep md5
    CHECK_RESULT $? 0 1 "Security reinforcement options are set."
    LOG_INFO "Finish testcase execution."
}

main "$@"
