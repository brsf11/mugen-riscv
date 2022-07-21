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
# @Desc      :   Client SSH hardening recommendations
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    grep "KexAlgorithms" /etc/ssh/ssh_config
    CHECK_RESULT $? 0 1 "Client SSH hardening is enabled."
    grep "VerifyHostKeyDNS" /etc/ssh/ssh_config
    CHECK_RESULT $? 0 1 "Client SSH hardening is enabled."
    LOG_INFO "Finish testcase execution."
}

main "$@"
