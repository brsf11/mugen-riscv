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
    ID=$(docker create --tmpfs tmpfs alpine ls)
    docker inspect $ID | grep tmpfs
    CHECK_RESULT $?
    ID=$(docker create --user root alpine ls)
    grep '"User":"root"' /var/lib/containers/storage/overlay-containers/$ID/userdata/artifacts/create-config
    CHECK_RESULT $?
    ID=$(docker create --userns host alpine ls)
    docker inspect $ID | grep '"UsernsMode": "host"'
    CHECK_RESULT $?
    ID=$(docker create --uts host alpine ls)
    docker inspect $ID | grep '"UTSMode": "host"'
    CHECK_RESULT $?
    docker create --name example alpine ls
    ID=$(docker create --volume /tmp:/tmp:z alpine ls)
    docker inspect $ID | grep '"destination": "/tmp"'
    CHECK_RESULT $?
    ID=$(docker create --volumes-from example alpine ls)
    grep '"VolumesFrom":\["example"\]' /var/lib/containers/storage/overlay-containers/$ID/userdata/artifacts/create-config
    CHECK_RESULT $?
    ID=$(docker create --workdir /tmp alpine ls)
    docker inspect $ID | grep '"WorkingDir": "/tmp"'
    CHECK_RESULT $?
    docker rmi -f $(docker images -q)
    CHECK_RESULT $?
    docker images | grep "postgres"
    CHECK_RESULT $? 1
    docker pull postgres:alpine
    docker images | grep "postgres"
    CHECK_RESULT $?
    docker rmi --all
    CHECK_RESULT $?
    docker images | grep "postgres"
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    rm -rf $(ls | grep -vE ".sh")
    LOG_INFO "End to restore the test environment."
}

main "$@"
