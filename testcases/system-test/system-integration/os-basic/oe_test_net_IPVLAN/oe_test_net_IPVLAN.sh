#!/usr/bin/bash

#Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-05-09
# @License   :   Mulan PSL v2
# @Desc      :   Ipvlan command test
# ############################################

source ../common/net_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    link_name="my_ipvlan"
    get_free_eth 1
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start to run test."
    ip link add link ${LOCAL_ETH[0]} name ${link_name} type ipvlan mode l2
    CHECK_RESULT $?
    ip addr add dev ${LOCAL_ETH[0]} 192.0.1.1/16
    CHECK_RESULT $?
    ip link set dev ${LOCAL_ETH[0]} up
    CHECK_RESULT $?
    ip a | grep "${link_name}"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ip link del ${link_name}
    nmcli con delete ${LOCAL_ETH[0]}
    LOG_INFO "End to restore the test environment."
}

main "$@"
