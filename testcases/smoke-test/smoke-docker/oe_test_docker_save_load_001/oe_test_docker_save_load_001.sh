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
# @Desc      :   Save an image to a tar package / tar package saved by docker reload an image
# ############################################

source ../common/prepare_docker.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    pre_docker_env
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    docker images | grep ${Images_name}
    CHECK_RESULT $?

    docker save -o ${Images_name}.tar ${Images_name}:latest
    CHECK_RESULT $?

    test -f ${Images_name}.tar
    CHECK_RESULT $?

    Images_id=$(docker images ${Images_name} -q)
    docker rmi ${Images_id}
    docker images | grep ${Images_name}
    CHECK_RESULT $? 1
    docker load -i ${Images_name}.tar
    CHECK_RESULT $?

    docker images | grep ${Images_name}
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ${Images_name}.tar
    clean_docker_env
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
