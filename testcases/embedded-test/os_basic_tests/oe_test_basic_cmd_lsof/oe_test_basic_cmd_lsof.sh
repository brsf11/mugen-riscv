#!/usr/bin/bash

#Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   saarloos
# @Contact   :   9090-90-90-9090@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   check basic commond lsof
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."

    lsof -i
    CHECK_RESULT $? 0 0 "run lsof fail"

    lsof -i:22 | grep sshd
    CHECK_RESULT $? 0 0 "check lsof sshd fail"

    lsof --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check lsof help fail"

    LOG_INFO "End to run test."
}

main "$@"
