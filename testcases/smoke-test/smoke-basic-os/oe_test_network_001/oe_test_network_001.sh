#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   nmcli, ip link, route, ip, ethtool, ifconfig command test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
card_name=$(ip a | grep 255 | grep -v ' virbr' | grep -v 'lo ' | grep -v 'docker' | awk -F' ' '{print $NF}')

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL net-tools
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    nmcli connection show | grep "${card_name}"
    CHECK_RESULT $?
    ip link | grep "${card_name}"
    CHECK_RESULT $?
    route | grep default
    CHECK_RESULT $?
    ethtool "${card_name}"
    CHECK_RESULT $?
    ifconfig | grep "${card_name}"
    CHECK_RESULT $?
    ip a show "${card_name}" | grep 192.1.1.11 && ip addr del 192.1.1.11 dev "${card_name}"
    ip addr add 192.1.1.11 dev "${card_name}"
    CHECK_RESULT $?
    ip a show "${card_name}" | grep 192.1.1.11
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    ip addr del 192.1.1.11 dev "${card_name}"
    LOG_INFO "Finish environment cleanup!"
}

main $@
