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
out_file="output.txt"
last_num=20

function pre_test() {
    LOG_INFO "Start environment preparation."
    SSH_CMD "dnf install -y criu gcc
    mkdir /root/checkpoint_demo" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    SSH_SCP demo.c "${NODE2_USER}"@"${NODE2_IPV4}":/root/ "${NODE2_PASSWORD}"
    SSH_CMD "gcc -o demo demo.c
    ./demo &
    echo \$!>demo_pid
    sleep 1
    criu dump -D /root/checkpoint_demo -j -t \$(cat demo_pid)" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"

    SSH_CMD "ps aux | grep demo | grep -w \$(cat demo_pid)" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}" && return 1
    let num1=$(SSH_CMD "cat $out_file | tail -1" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}" | tail -n 1 | awk -F '\r' '{print $1}')

    SSH_CMD "criu restore -D /root/checkpoint_demo -j" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    let num2=num1+1
    SSH_CMD "cat $out_file | grep -w $last_num" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    SSH_CMD "cat $out_file | grep -w $num2" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    SSH_CMD "rm -rf checkpoint_demo demo demo.c $out_file
    dnf remove -y criu gcc" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "Finish environment cleanup!"
}

main $@
