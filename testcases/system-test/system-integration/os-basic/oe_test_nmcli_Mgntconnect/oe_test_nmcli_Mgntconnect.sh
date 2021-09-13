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
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Use nmcli to manage network connections after the installation process
# ############################################

source ../common/net_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    get_free_eth 1
    test_eth=${LOCAL_ETH[0]}
    con_name="ethernet-${test_eth}"
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    nmcli con show ${con_name} && nmcli con delete ${con_name}
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    nmcli con add type ethernet ifname ${test_eth} | grep successfully
    CHECK_RESULT $?
    nmcli -a con add >log <<EOF
ethernet
ethernet
no
no
no
no
EOF
    grep successfully log
    CHECK_RESULT $?
    nmcli con mod ${con_name} ipv4.method auto
    CHECK_RESULT $?
    nmcli connection show ${con_name} | grep ipv4.method | grep auto
    CHECK_RESULT $?
    nmcli connection edit ${con_name} >log <<EOF
print
help
quit
EOF
    grep -c "nmcli>" log | grep 3
    CHECK_RESULT $?
    CHECK_RESULT $(nmcli con show | grep -c ${con_name}) 1
    num_nmcli=$(nmcli con show ${con_name} | grep -c connection)
    test $num_nmcli -gt 10
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf log
    nmcli con delete ${con_name}
    LOG_INFO "End to restore the test environment."
}

main "$@"
