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
    ID=$(podman create --read-only alpine ls)
    podman inspect $ID | grep '"ReadonlyRootfs": true'
    CHECK_RESULT $?
    podman create --rm alpine ls
    CHECK_RESULT $?
    ID=$(podman create --security-opt apparmor=unconfined alpine ls)
    podman inspect $ID | grep 'apparmor=unconfined'
    CHECK_RESULT $?
    ID=$(podman create --shm-size 65536k alpine ls)
    podman inspect $ID | grep '"ShmSize": 65536000'
    CHECK_RESULT $?
    ID=$(podman create --stop-signal 20 alpine ls)
    podman inspect $ID | grep '"StopSignal": 20'
    CHECK_RESULT $?
    podman create --stop-timeout 10 alpine ls
    CHECK_RESULT $?
    ID=$(podman create --storage-opt overlay alpine ls)
    podman inspect $ID | grep '"Name": "overlay"'
    CHECK_RESULT $?
    ID=$(podman create --sysctl net.ipv6.conf.all.disable_ipv6=1 alpine ls)
    grep '"net.ipv6.conf.all.disable_ipv6":"1"' /var/lib/containers/storage/overlay-containers/$ID/userdata/artifacts/create-config
    CHECK_RESULT $?
    ID=$(podman create --systemd alpine ls)
    grep '"Systemd":false' /var/lib/containers/storage/overlay-containers/$ID/userdata/artifacts/create-config
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
