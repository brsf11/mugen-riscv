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
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   Create a new tuned profile
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL tuned
    systemctl enable --now tuned
    mkdir /etc/tuned/my-profile
    old_profile=$(tuned-adm active | awk '{print $4}')
    echo "[main]
summary=General non-specialized tuned profile
[cpu]
governor=conservative
energy_perf_bias=normal
[audio]
timeout=10
[video]
radeon_powersave=dpm-balanced, auto" >/etc/tuned/my-profile/tuned.conf
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."     
    tuned-adm profile my-profile
    CHECK_RESULT $?
    tuned-adm active | grep "my-profile"
    CHECK_RESULT $?
    tuned-adm verify | grep "succeeded"
    CHECK_RESULT $?
    tuned-adm profile "$old_profile"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf tuned_log /etc/tuned
    LOG_INFO "End to restore the test environment."
}

main $@
