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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/10/12
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in ndisc6 package
# ############################################

source "../common/common_ndisc6.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rdnssd -f &
    kill -9 $(pgrep -w nss)
    rdnssd -H /etc/rdnssd/merge-hook
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "/etc/rdnssd/merge-hook" | head -n -1 | awk '{print $2}')
    rdnssd -p /var/run/rdnssd.pid
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "/var/run/rdnssd.pid" | head -n -1 | awk '{print $2}')
    rdnssd -r /etc/resolv.conf
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "/etc/resolv.conf" | head -n -1 | awk '{print $2}')
    rdnssd -u nobody
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "rdnssd -u nobody" | head -n -1 | awk '{print $2}')
    ndisc6_version=$(rpm -qa ndisc6 | awk -F '-' '{print $2}')
    rdnssd -V | grep "${ndisc6_version}"
    CHECK_RESULT $?
    rdnssd -h | grep rdnssd
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
