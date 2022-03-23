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
# @Desc      :   The usage of commands in docker package
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
    docker help | grep -E "docker|help"
    CHECK_RESULT $?
    docker create alpine
    CHECK_RESULT $?
    docker ps -a | grep -i "Created"
    CHECK_RESULT $?
    ID=$(docker create --add-host host:192.168.122.172 alpine)
    grep "192.168.122.172" /var/lib/containers/storage/overlay-containers/$ID/userdata/artifacts/create-config
    CHECK_RESULT $?
    ID=$(docker create --annotation HELLO=WORLD alpine)
    docker inspect $ID | grep '"HELLO": "WORLD"'
    CHECK_RESULT $?
    docker create --attach STDIN alpine ls
    CHECK_RESULT $?
    docker ps -a | grep ls
    CHECK_RESULT $?
    ID=$(docker create --blkio-weight 15 alpine ls)
    docker inspect $ID | grep '"BlkioWeight": 15'
    CHECK_RESULT $?
    ID=$(docker create --blkio-weight-device /dev/:15 fedora ls)
    docker inspect $ID | grep '"weight": 15'
    CHECK_RESULT $?
    ID=$(docker create --cap-add net_admin alpine ls)
    docker inspect $ID | grep -A 1 "CapAdd" | grep "net_admin"
    CHECK_RESULT $?
    ID=$(docker create --cap-drop net_admin alpine ls)
    docker inspect $ID | grep -A 1 "CapDrop" | grep "net_admin"
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
