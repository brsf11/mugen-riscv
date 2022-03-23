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
# @Date      :   2020/01/11
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
    podman help | grep -E "podman|help"
    CHECK_RESULT $?
    podman create alpine
    CHECK_RESULT $?
    podman ps -a | grep -i "Created"
    CHECK_RESULT $?
    ID=$(podman create --add-host host:192.168.122.172 alpine)
    grep "192.168.122.172" /var/lib/containers/storage/overlay-containers/$ID/userdata/artifacts/create-config
    CHECK_RESULT $?
    ID=$(podman create --annotation HELLO=WORLD alpine)
    podman inspect $ID | grep '"HELLO": "WORLD"'
    CHECK_RESULT $?
    podman create --attach STDIN alpine ls
    CHECK_RESULT $?
    podman ps -a | grep ls
    CHECK_RESULT $?
    ID=$(podman create --blkio-weight 15 alpine ls)
    podman inspect $ID | grep '"BlkioWeight": 15'
    CHECK_RESULT $?
    ID=$(podman create --blkio-weight-device /dev/:15 fedora ls)
    podman inspect $ID | grep '"weight": 15'
    CHECK_RESULT $?
    ID=$(podman create --cap-add net_admin alpine ls)
    podman inspect $ID | grep -A 1 "CapAdd" | grep "net_admin"
    CHECK_RESULT $?
    ID=$(podman create --cap-drop net_admin alpine ls)
    podman inspect $ID | grep -A 1 "CapDrop" | grep "net_admin"
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
