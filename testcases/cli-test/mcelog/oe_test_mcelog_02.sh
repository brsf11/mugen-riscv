#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2021-1-5
#@License       :   Mulan PSL v2
#@Desc          :   mcelog is a tool used to check for hardware error on x86 Linux.
#####################################

source "${OET_PATH}/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    if [ "${NODE1_FRAME}" != "x86_64" ]; then
        echo "Non X86 architecture,this function is not supported"
        exit
    else
        DNF_INSTALL mcelog
    fi
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mcelog --cpu k8
    CHECK_RESULT $?
    mcelog --cpu p4
    CHECK_RESULT $?
    mcelog --cpu core2
    CHECK_RESULT $?
    mcelog --cpu generic
    CHECK_RESULT $?
    mcelog --cpumhz 50
    CHECK_RESULT $?
    mcelog --raw
    CHECK_RESULT $?
    mcelog --daemon --syslog-error --dmi --no-imc-log --filter --num-errors N
    CHECK_RESULT $?
    mcelog_id1=$(pgrep -f "mcelog --daemon --syslog-error --dmi --no-imc-log --filter --num-errors N")
    CHECK_RESULT $?
    kill -9 $mcelog_id1
    CHECK_RESULT $?
    mcelog --daemon --no-syslog --no-dmi --no-filter
    CHECK_RESULT $?
    mcelog_id2=$(pgrep -f "mcelog --daemon --no-syslog --no-dmi --no-filter")
    CHECK_RESULT $?
    kill -9 $mcelog_id2
    CHECK_RESULT $?
    mcelog --is-cpu-supported
    CHECK_RESULT $?
    nohup mcelog --daemon --foreground &
    CHECK_RESULT $?
    kill -9 $(pgrep -f "mcelog --daemon --foreground")
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
