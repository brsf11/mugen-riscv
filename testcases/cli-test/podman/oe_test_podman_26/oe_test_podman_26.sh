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
# @Desc      :   podman build
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
    cp ../common/* .
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    podman build . >> test.log
    CHECK_RESULT $?
    id=`cat test.log | awk '{print $2}'`
    echo ${id}
    cat ./Dockerfile | podman build -f - . | grep ${id}
    CHECK_RESULT $?
    podman build --runtime-flag debug . | grep ${id}
    CHECK_RESULT $?
    podman build --authfile /tmp/auths/myauths.json --cert-dir $HOME/auth --tls-verify=true --creds=username:password -t hjfd -f ./Dockerfile.simple . | grep ${id}
    CHECK_RESULT $?
    podman build --memory 40m --cpu-period 10000 --cpu-quota 50000 --ulimit nofile=1024:1028 -t imagenam . | grep ${id}
    CHECK_RESULT $?
    podman build -f Dockerfile.simple -f Containerfile.notsosimple . | grep ${id}
    CHECK_RESULT $?
    podman build -f Dockerfile.in ${HOME} | grep ${id}
    CHECK_RESULT $?
    podman build --no-cache --rm=false -t newimages1 . 
    CHECK_RESULT $?
    podman build --layers --force-rm -t testname .  
    CHECK_RESULT $?
    podman build --no-cache -t imageert . 
    CHECK_RESULT $?
    podman rmi -force --all
    CHECK_RESULT $?
    LOG_INFO "End executing testcase."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf Docker* Containerfile* common* test.log
    clear_env
    LOG_INFO "Finish environment cleanup."
}

main $@
