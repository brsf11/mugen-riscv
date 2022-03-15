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
    ID=$(podman create --oom-kill-disable alpine ls)
    podman inspect $ID | grep '"OomKillDisable": true'
    CHECK_RESULT $?
    ID=$(podman create --oom-score-adj 100 alpine ls)
    podman inspect $ID | grep '"OomScoreAdj": 100'
    CHECK_RESULT $?
    ID=$(podman create --pid host alpine ls)
    podman inspect $ID | grep '"PidMode": "host"'
    CHECK_RESULT $?
    ID=$(podman create --pids-limit 3 alpine ls)
    podman inspect $ID | grep '"PidsLimit": 3'
    CHECK_RESULT $?
    podman pod create --infra=false
    ID=$(podman create --pod $(podman pod list -lq) alpine ls)
    podman rm $ID
    CHECK_RESULT $?
    podman pod rm $(podman pod list -q)
    ID=$(podman create --privileged alpine ls)
    podman inspect $ID | grep '"Privileged": true'
    CHECK_RESULT $?
    ID=$(podman create --publish 23 alpine ls)
    podman inspect $ID | grep '"containerPort": 23'
    CHECK_RESULT $?
    ID=$(podman create --publish-all alpine ls)
    podman inspect $ID | grep '"PublishAllPorts": false'
    CHECK_RESULT $?
    podman create -q alpine ls
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
