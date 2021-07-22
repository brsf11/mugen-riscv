#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.
# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Common options of ssh-keyscan
# #############################################
source "${OET_PATH}/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    ssh-keyscan "${NODE2_IPV4}" | grep "ssh-rsa"
    CHECK_RESULT $?
    ssh-keyscan -v "${NODE2_IPV4}" 2>&1 | grep "debug"
    CHECK_RESULT $?
    ssh-keyscan -t ed25519 "${NODE2_IPV4}" | grep "ed25519"
    CHECK_RESULT $?
    ssh-keyscan localhost | grep "ed25519"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

main "$@"
