#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   hejinjin
#@Contact       :   jinjin@isrc.iscas.ac.cn
#@Date          :   2021/12/19
#@License       :   Mulan PSL v2
#@Desc          :   netperf command line test public functions
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_env() {
    DNF_INSTALL "netperf"
    DNF_INSTALL "netperf" 2
    rdport=$(GET_FREE_PORT "$NODE2_IPV4")
    P_SSH_CMD --cmd "systemctl stop firewalld"
}

function clean_env() {
    P_SSH_CMD --cmd "systemctl start firewalld"
    DNF_REMOVE 0
}

function test_server() {
    netperf -H "$NODE2_IPV4" -p ${rdport} -l 1 | grep $1
    CHECK_RESULT $? 0 0 "after netserver $2,netperf execution failed."
    P_SSH_CMD --cmd "pkill -9 netserver
        netstat -apn" | grep netserver
    CHECK_RESULT $? 0 1 "pkill -9 netserver execution failed."
    SLEEP_WAIT 1
}