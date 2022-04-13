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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-06-08
# @License   :   Mulan PSL v2
# @Desc      :   Start / stop / delete container
# ############################################

source ../common/prepare_docker.sh
function config_params() {
    LOG_INFO "Start loading data."
    container_name=container_test
    LOG_INFO "Loading data is complete."
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    pre_docker_env
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    docker run -itd --name=${container_name} ${Images_name}
    CHECK_RESULT $?
    docker inspect -f {{.State.Status}} ${container_name} | grep running
    CHECK_RESULT $?

    docker stop ${container_name}
    CHECK_RESULT $?
    docker inspect -f {{.State.Status}} ${container_name} | grep exited
    CHECK_RESULT $?

    docker start ${container_name}
    CHECK_RESULT $?
    docker inspect -f {{.State.Status}} ${container_name} | grep running
    CHECK_RESULT $?
    docker kill ${container_name}
    CHECK_RESULT $?
    docker inspect -f {{.State.Status}} ${container_name} | grep exited
    CHECK_RESULT $?
    docker rm ${container_name}
    CHECK_RESULT $?
    docker ps -a | grep ${container_name}
    CHECK_RESULT $? 1

    docker run -itd --name=${container_name} ${Images_name}
    CHECK_RESULT $?
    docker inspect -f {{.State.Status}} ${container_name} | grep running
    CHECK_RESULT $?
    docker stop ${container_name}
    CHECK_RESULT $?
    docker rm -f ${container_name}
    CHECK_RESULT $?
    docker ps -a | grep ${container_name}
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    clean_docker_env
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
