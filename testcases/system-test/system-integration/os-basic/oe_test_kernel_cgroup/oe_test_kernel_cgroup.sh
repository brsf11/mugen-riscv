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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020.4.27
# @License   :   Mulan PSL v2
# @Desc      :   cgroup
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to pre test."
    echo "#!/bin/bash
while true
do
    sleep 1
done" >testcgroup.sh
    sh testcgroup.sh &
    pid=$(pgrep -f "sh testcgroup.sh")
    mkdir /sys/fs/cgroup/memory/example
    LOG_INFO "Start to pre test."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    echo 1000000 >/sys/fs/cgroup/memory/example/memory.limit_in_bytes
    CHECK_RESULT $?
    echo ${pid} >/sys/fs/cgroup/memory/example/cgroup.procs
    CHECK_RESULT $?
    ps -o cgroup ${pid} | grep devices | grep pids
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    kill -9 ${pid}
    rm -rf testcgroup.sh
    LOG_INFO "Finish environment cleanup."
}

main $@
