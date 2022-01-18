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
# @Author    :   duanxuemin
# @Contact   :   duanxuemin@foxmail.com
# @Date      :   2020.4.27
# @License   :   Mulan PSL v2
# @Desc      :   podman rm Test
# ############################################

source ../common/common_podman.sh
function config_params() {
    LOG_INFO "Start loading data!"
    name="postgres"
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    deploy_env
    podman rm -all
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    value=$(podman run --name ${name} -e POSTGRES_PASSWORD=secret -d postgres:alpine)
    CHECK_RESULT $?
    podman ps -a | grep ${name}
    CHECK_RESULT $?
    podman stop ${name} | grep ${value}
    CHECK_RESULT $?
    podman rm ${name} | grep ${value}
    CHECK_RESULT $?
    id1=$(podman run --name ${name}1 -e POSTGRES_PASSWORD=secret -d postgres:alpine)
    CHECK_RESULT $?
    podman ps -a | grep ${name}1
    CHECK_RESULT $?
    podman stop ${name}1 | grep ${id1}
    CHECK_RESULT $?
    podman rm ${id1}
    CHECK_RESULT $?
    id2=$(podman run --name ${name}2 -e POSTGRES_PASSWORD=secret -d postgres:alpine)
    CHECK_RESULT $?
    id3=$(podman run --name ${name}3 -e POSTGRES_PASSWORD=secret -d postgres:alpine)
    CHECK_RESULT $?
    podman stop ${name}2 ${name}3 
    CHECK_RESULT $?
    podman rm ${name}2 ${name}3 | grep ${id3}
    CHECK_RESULT $?
    LOG_INFO "End executing testcase."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    clear_env
    LOG_INFO "Finish environment cleanup."
}

main $@
