#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   lutianxiong
# @Contact   :   lutianxiong@huawei.com
# @Date      :   2020-11-20
# @License   :   Mulan PSL v2
# @Desc      :   criu test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    last_num=300
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "criu gcc"
    mkdir checkpoint_demo
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    gcc -o demo demo.c
    ./demo &
    echo $! >demo_pid
    sleep 1
    criu dump -D checkpoint_demo -j -t $(cat demo_pid)
    CHECK_RESULT $?
    ps aux | grep demo | grep -w $(cat demo_pid)
    CHECK_RESULT $? 1
    num1=$(cat output.txt | tail -1)
    criu restore -D ./checkpoint_demo -j
    CHECK_RESULT $?
    let num2=num1+1
    grep -w $last_num output.txt
    CHECK_RESULT $?
    grep -w $num2 output.txt
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf checkpoint_demo demo output.txt demo_pid
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@
