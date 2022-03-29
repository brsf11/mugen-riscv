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
    ID=$(docker create --cgroup-parent machine.slice alpine ls)
    docker inspect $ID | grep '"CgroupParent": "machine.slice"'
    CHECK_RESULT $?
    ID=$(docker create --cidfile cidfile alpine ls)
    grep $ID cidfile
    CHECK_RESULT $?
    ID=$(docker create --conmon-pidfile ./ alpine ls)
    docker inspect $ID | grep $ID
    CHECK_RESULT $?
    ID=$(docker create --cpu-period 10000 alpine ls)
    docker inspect $ID | grep '"CpuPeriod": 10000'
    CHECK_RESULT $?
    ID=$(docker create --cpu-quota 1001 alpine ls)
    docker inspect $ID | grep '"CpuQuota": 1001'
    CHECK_RESULT $?
    ID=$(docker create --cpu-rt-period 1 alpine ls)
    docker inspect $ID | grep '"CpuRealtimePeriod": 1'
    CHECK_RESULT $?
    ID=$(docker create --cpu-rt-runtime 2 alpine ls)
    docker inspect $ID | grep '"CpuRealtimeRuntime": 2'
    CHECK_RESULT $?
    ID=$(docker create --cpu-shares 3 alpine ls)
    docker inspect $ID | grep '"CpuShares": 3'
    CHECK_RESULT $?
    ID=$(docker create --cpus 4 alpine ls)
    docker inspect $ID | grep '"CpuQuota": 400000'
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
