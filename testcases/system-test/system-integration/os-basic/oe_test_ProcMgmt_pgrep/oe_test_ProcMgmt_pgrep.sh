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
# @Date      :   2020-05-09
# @License   :   Mulan PSL v2
# @Desc      :   View process status-pgrep
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start to run test."
    line=1
    for ps_pid in $(ps -ef | pgrep ssh | grep -v "grep" | awk '{print$2}')
    do
        pgrep -l ssh | sed -n ${line}p | grep ${ps_pid}
        CHECK_RESULT $?
        ((line++))
    done
    pgrep -l ssh | sed -n 1p | grep "$(pgrep -l -o ssh)"
    CHECK_RESULT $?
    pgrep -l ssh | awk 'END{print$1,$2}' | grep "$(pgrep -l -n ssh)"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

main "$@"
