#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   dingjiao
#@Contact   	:   15829797643@163.com
#@Date      	:   2022-07-06
#@License   	:   Mulan PSL v2
#@Desc      	:   Get CPU overhead
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    DNF_INSTALL sysstat
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mpstat 3 2 | grep -v "CPU" | grep -v "Average" >mpstat.log
    CHECK_RESULT $? 0 0 "Get cpu overhead: failed"
    sed -i '1d' ./mpstat.log
    date_list=()
    line=0
    for date in $(awk '{print$1}' ./mpstat.log); do
        date_list[line]=$(date -d $(date) +%s)
        let line+=1
    done
    CHECK_RESULT ${#date_list[*]} 2 0 "Get cpu overhead twice: failed!"
    CHECK_RESULT $(${date_list[1]} - ${date_list[0]}) 3 0 "The cpu overhead s obtained every 3s: failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF REMOVE
    rm -rf perf.check mpstat.log
    export LANG=${OLD_LANG}
    LOG_INFO "End to restore the test environment."
}

main "$@"
