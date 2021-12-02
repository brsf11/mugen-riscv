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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Command test-who -b/-s
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start to run test."
    who | grep $(users | awk '{print$1}')
    CHECK_RESULT $?

    who -b | grep "system boot"
    CHECK_RESULT $?

    who -s | grep pts
    CHECK_RESULT $?

    who --help | grep "Usage"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

main "$@"
