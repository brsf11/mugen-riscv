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
# @Date      :   2020-04-28
# @License   :   Mulan PSL v2
# @Desc      :   Run a batch of programs regularly-at
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL at
    systemctl start atd
    time=$(date "+%Y-%m-%d %H:%M:%S")
    old_count=$(atq | wc -l)
    if [ ${old_count} -eq 0 ]; then
        atq_flag=0
    else
        atq_flag=$(atq | sort -r | awk '{print$1}' | sed -n 1p)
    fi
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    echo -e "echo hello1 > /tmp/test" | at 11:30pm
    echo -e "echo hello2 > /tmp/test" | at 16:35
    echo -e "echo hello3 > /tmp/test" | at now+4 hours
    echo -e "echo hello4 > /tmp/test" | at now+240 minutes
    echo -e "echo hello5 > /tmp/test" | at 16:30 12.12.29
    echo -e "echo hello6 > /tmp/test" | at 16:30 12/12/29
    echo -e "echo hello7 > /tmp/test" | at 16:30 Dec 12
    new_count=$(atq | wc -l)
    CHECK_RESULT "${new_count}" $((${old_count} + 7))
    date -s "23:29:30"
    rm -rf /tmp/test
    SLEEP_WAIT 60
    grep "hello1" /tmp/test
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    for i in $(seq $(($atq_flag + 1)) $(($atq_flag + 7))); do
        atrm ${i}
    done
    date -s "$time 1 minute"
    rm -rf /tmp/test
    DNF_REMOVE 
    LOG_INFO "End to restore the test environment."
}

main "$@"
