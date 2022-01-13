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
# @Date      :   2022/1/5 
# @License   :   Mulan PSL v2
# @Desc      :   Common lib for test prometheus
# #############################################

source "../common/common_lib.sh"

function is_running() {
    if pgrep -x "prometheus" >/dev/null; then
        return 0
    else
        return 1
    fi
}

function wait_for_ready() {
    LOG_INFO "Waiting for Prometheus to be ready."
    while ! grep "Server is ready to receive web requests." ./prometheus.log; do
        sleep 1s
    done
    LOG_INFO "Prometheus is ready."
}

function kill_process() {
    if is_running; then
        kill -9 "$(pgrep -x 'prometheus')"
        if pgrep -x "prometheus" >/dev/null; then
            LOG_WARN "Failed to terminate prometheus."
        else
            LOG_INFO "Succeed to terminate prometheus."
        fi
    fi
}

function clear_env() {
    kill_process
    rm -rf ./data
    rm -rf ./prometheus.log
    rm -rf ./the_data
}
