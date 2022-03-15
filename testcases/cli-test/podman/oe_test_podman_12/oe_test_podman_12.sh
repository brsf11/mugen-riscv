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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2021/01/11
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in podman package
# ############################################

source "../common/common_podman.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    podman pull postgres:alpine
    podman run --name postgres -e POSTGRES_PASSWORD=secret -d postgres:alpine
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ID=$(podman create -t -i --name myctr alpine ls)
    podman inspect $ID | grep '"Name": "myctr"'
    CHECK_RESULT $?
    ID=$(podman create --hostname localhost alpine ls)
    podman inspect $ID | grep '"Hostname": "localhost"'
    CHECK_RESULT $?
    ID=$(podman create --image-volume bind alpine ls)
    podman inspect $ID | grep -i bind
    CHECK_RESULT $?
    ID=$(podman create --builtin-volume tmpfs alpine ls)
    podman inspect $ID | grep -i tmpfs
    CHECK_RESULT $?
    ID=$(podman create --ip ${NODE1_IPV4} alpine ls)
    podman inspect $ID | grep -i ip
    CHECK_RESULT $?
    ID=$(podman create --ipc host alpine ls)
    podman inspect $ID | grep '"IpcMode": "host"'
    CHECK_RESULT $?
    ID=$(podman create --kernel-memory 1g alpine ls)
    podman inspect $ID | grep '"KernelMemory": 1073741824'
    CHECK_RESULT $?
    ID=$(podman create --label com.example.key=value alpine ls)
    podman inspect $ID | grep '"com.example.key": "value"'
    CHECK_RESULT $?
    echo "com.example.key=value" >./a
    ID=$(podman create --label-file ./a alpine ls)
    podman inspect $ID | grep '"com.example.key": "value"'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    rm -rf $(ls | grep -vE ".sh")
    LOG_INFO "End to restore the test environment."
}

main "$@"
