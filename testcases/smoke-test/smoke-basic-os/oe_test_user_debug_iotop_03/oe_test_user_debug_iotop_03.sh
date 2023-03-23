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
#@Desc      	:   Displays the i/o that the process or thread is actually doing
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL iotop
    echo "#!/bin/bash
while true
do
   echo 'iotop test'>test
done" >iotoptest
    chmod u+x iotoptest
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ./iotoptest &
    CHECK_RESULT $? 0 0 "Execute i/o process:failed"
    iotop -o -b -n 2 -d 10 | grep "iotoptest"
    CHECK_RESULT $? 0 0 "Failed to check the running i/o process"
    running_io_total=$(iotop -o -b -n 1 -d 10 | wc -l)
    all_io_total=$(iotop -b -n 1 -d 10 | wc -l)
    test $all_io_total > $running_io_total
    CHECK_RESULT $? 0 0 "Failed to check the all i/o process!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF REMOVE
    kill -9 $(ps -ef | grep iotoptest | grep -v grep | awk '{print $2}')
    rm -rf test iotoptest
    LOG_INFO "End to restore the test environment."
}

main "$@"
