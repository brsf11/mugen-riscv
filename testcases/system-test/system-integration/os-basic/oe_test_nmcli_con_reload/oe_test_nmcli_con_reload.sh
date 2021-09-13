#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2020-06-06
# @License   :   Mulan PSL v2
# @Desc      :   Test nmcli reload
# ############################################

source ../common/net_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    get_free_eth 1
    test_eth=${LOCAL_ETH[0]}
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start to run test."
    sed -i "s/testintf/${test_eth}/g" ifcfg-test
    cp ifcfg-test /etc/sysconfig/network-scripts/ifcfg-${test_eth} -rf
    CHECK_RESULT $?
    nmcli con reload
    CHECK_RESULT $?
    test -f /etc/sysconfig/network-scripts/ifcfg-${test_eth}
    CHECK_RESULT $?

    sed -i 's/dhcp/static/g' /etc/sysconfig/network-scripts/ifcfg-${test_eth}
    {
        echo "IPADDR=192.0.2.100"
        echo "NETMASK=255.255.255.0"
        echo "GATEWAY=192.0.2.1"
    } >>/etc/sysconfig/network-scripts/ifcfg-${test_eth}
    nmcli con reload
    CHECK_RESULT $?
    nmcli con up ${test_eth}
    CHECK_RESULT $?
    nmcli con show --active | grep ${test_eth}
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    nmcli con delete ${test_eth}
    sed -i "s/${test_eth}/testintf/g" ifcfg-test
    LOG_INFO "End to restore the test environment."
}

main "$@"
