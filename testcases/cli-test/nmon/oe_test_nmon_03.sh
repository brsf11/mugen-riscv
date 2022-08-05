#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   zhangjujie2
#@Contact   	:   zhangjujie43@gmail.com
#@Date      	:   2022/08/04
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test for nmon
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "nmon"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    mkdir -p /var/perf/tmp/
    nmon -z
    test -f /var/perf/tmp/*.nmon
    CHECK_RESULT $? 0 0 "Failed option: -z"
    ls -l /var/perf/tmp/* | grep .nmon | awk '{print $3}' | grep root
    CHECK_RESULT $? 0 0 "Failed option: -z"
    grep -E 'interval,900|snapshots,96' /var/perf/tmp/*.nmon
    CHECK_RESULT $? 0 0 "Failed option: -z"
    LOG_INFO "End to run test."
    nmon -x
    SLEEP_WAIT 2
    grep -E 'interval,900|snapshots,96|TOP' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -x"
    rm -rf *.nmon
    nmon -X
    SLEEP_WAIT 2
    grep -E 'interval,30|snapshots,120|TOP' *.nmon
    CHECK_RESULT $? 0 0 "Failed option: -X"
    rm -rf *.nmon
}

function post_test() {
    LOG_INFO "Start restore the test environment."
    rm -rf /var/perf/
    kill -USR2 $(pgrep -w nmon)
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"

