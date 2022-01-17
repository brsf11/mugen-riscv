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
# @Desc      :   podman-mount-unmount
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
    podman pull postgres:alpine
    CHECK_RESULT $?
    id=$(podman run --name ${name} -e POSTGRES_PASSWORD=secret -d postgres:alpine)
    CHECK_RESULT $?
    podman start ${name}
    CHECK_RESULT $?
    podman top -l | grep "USER"
    CHECK_RESULT $?
    podman top ${name} | grep "USER"
    CHECK_RESULT $?
    podman mount --format json | grep "id"
    CHECK_RESULT $?
    podman mount --notruncate | grep merged
    CHECK_RESULT $?
    podman stop ${name} | grep ${id}
    CHECK_RESULT $?
    podman unmount -f ${name} | grep ${id}
    CHECK_RESULT $?
    podman mount ${name} 
    CHECK_RESULT $?
    podman unmount --all
    CHECK_RESULT $?
    podman rm ${name} | grep ${id}
    CHECK_RESULT $?
    LOG_INFO "End executing testcase."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    clear_env
    LOG_INFO "Finish environment cleanup."
}

main $@
