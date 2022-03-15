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
    ID=$(podman create --dns 255.255.255.0 alpine ls)
    podman inspect $ID | grep "255.255.255.0"
    CHECK_RESULT $?
    ID=$(podman create --dns-opt 8.8.8.8 alpine ls)
    podman inspect $ID | grep "8.8.8.8"
    CHECK_RESULT $?
    ID=$(podman create --dns-search domain alpine ls)
    podman inspect $ID | grep "domain"
    CHECK_RESULT $?
    ID=$(podman create --name ctr --env ENV*****=b alpine printenv ENV*****)
    podman inspect $ID | grep "ENV****"
    CHECK_RESULT $?
    echo "ENV*****=b" >./a
    ID=$(podman create --env-file ./a alpine ls)
    podman inspect $ID | grep "ENV"
    CHECK_RESULT $?
    ID=$(podman create --expose 0 alpine ls)
    podman inspect $ID | grep "0"
    CHECK_RESULT $?
    ID=$(podman create --uidmap 0:30000:7000 --gidmap 0:30000:7000 fedora echo hello)
    podman inspect $ID | grep '"gid": 0'
    CHECK_RESULT $?
    ID=$(podman create --group-add groups alpine ls)
    podman inspect $ID | grep -i group
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
