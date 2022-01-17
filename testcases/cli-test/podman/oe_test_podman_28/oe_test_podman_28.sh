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
# @Desc      :   Backup / restore database
# ############################################

source ../common/common_podman.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    deploy_env
    podman rm -all
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    podman pod create --infra=false
    CHECK_RESULT $?
    name=$(podman pod ls | sed -n 2p | awk {'print$2'})
    CHECK_RESULT $?
    podman pod ls | grep ${name}
    CHECK_RESULT $?
    podman pod ps | grep ${name}
    CHECK_RESULT $?
    podman pod list | grep ${name}
    CHECK_RESULT $?
    podman pod pause ${name}
    CHECK_RESULT $?
    podman pod unpause ${name}
    CHECK_RESULT $?
    podman pod inspect ${name}
    CHECK_RESULT $?
    nohup openvpn podman pod stats ${name} >/dev/null 2>&1 &
    local_pid=$(echo $!)
    CHECK_RESULT $?
    podman pod stop ${name}
    CHECK_RESULT $?
    podman pod rm ${name}
    CHECK_RESULT $?
    LOG_INFO "End executing testcase."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    clear_env
    kill -9 $local_pid
    LOG_INFO "Finish environment cleanup."
}

main $@
