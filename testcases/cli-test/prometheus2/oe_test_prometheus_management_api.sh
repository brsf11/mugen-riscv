#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   shangyingjie
# @Contact   :   yingjie@isrc.iscas.ac.cn
# @Date      :   2022/1/13
# @License   :   Mulan PSL v2
# @Desc      :   Test Prometheus management API
# #############################################

source "./common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL prometheus2
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    prometheus --config.file="prometheus.yml" > prometheus.log 2>&1 &
    wait_for_ready
    curl -s 'http://localhost:9090/-/healthy' | grep 'Prometheus is Healthy.'
    CHECK_RESULT $? 0 0 "Failed use api: health."
    curl -s 'http://localhost:9090/-/ready' | grep 'Prometheus is Ready.'
    CHECK_RESULT $? 0 0 "Failed use api: readiness."
    clear_env
    prometheus --web.enable-lifecycle > prometheus.log 2>&1 &
    wait_for_ready
    curl -s -X POST 'http://localhost:9090/-/reload'
    CHECK_RESULT $? 0 0 'Failed to use api: reload'
    curl -s -X POST 'http://localhost:9090/-/quit'
    CHECK_RESULT $? 0 0 'Failed to use api: quit'
    clear_env
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
