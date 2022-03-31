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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-28
# @License   :   Mulan PSL v2
# @Desc      :   Run a batch of programs regularly-at
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL at
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    echo -e "ls\n\004\n" | at 4:30pm
    echo -e "ls\n\004\n" | at 16:35
    echo -e "ls\n\004\n" | at now+4 hours
    echo -e "ls\n\004\n" | at now+ 240 minutes
    echo -e "ls\n\004\n" | at 16:30 12.12.29
    echo -e "ls\n\004\n" | at 16:30 12/12/29
    echo -e "ls\n\004\n" | at 16:30 Dec 12
    ret=$(atq | wc -l)
    CHECK_RESULT "$ret" 7
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    atrm $(atq | awk -F " " '{print$1}')
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
