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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   Setting up the disk scheduler using Tuned(For physical machines only)
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "tuned dmidecode"
    if [[ "$(dmidecode -s system-product-name)" =~ "KVM" ]]; then
        LOG_INFO "This only applies to physical machines."
        exit 0
    fi
    systemctl enable --now tuned
    mkdir /etc/tuned/my-profile_new
    echo "[main]
summary=General non-specialized tuned profile
[cpu]
governor=conservative
energy_perf_bias=normal
[audio]
timeout=10
[video]
radeon_powersave=dpm-balanced, auto" >/etc/tuned/my-profile_new/tuned.conf
    TEST_DISK=$(lsblk | grep disk | grep -v ":0" | awk '{print$1}' | sed -n 1p)
    old_scheduler=$(awk -F '[' '{print$2}' /sys/block/"${TEST_DISK}"/queue/scheduler | awk -F ']' '{print$1}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    old_profile=$(tuned-adm active | awk '{print $4}')
    mkdir /etc/tuned/my-profile
    ID_WWN=$(udevadm info --query=property --name=/dev/"$TEST_DISK" | grep WWN=)
    echo "[main]
include=my-profile_new
[disk]
devices_udev_regex=$ID_WWN
elevator=mq-deadline" >/etc/tuned/my-profile/tuned.conf
    tuned-adm profile my-profile
    CHECK_RESULT $?
    tuned-adm active | grep "my-profile"
    CHECK_RESULT $?
    tuned-adm verify | grep "succeeded"
    CHECK_RESULT $?
    awk -F '[' '{print$2}' /sys/block/"${TEST_DISK}"/queue/scheduler | awk -F ']' '{print$1}' | grep mq-deadline
    CHECK_RESULT $?
    tuned-adm profile "$old_profile"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /etc/tuned/my-profile /etc/tuned/my-profile_new
    echo "${old_scheduler}" >/sys/block/"$TEST_DISK"/queue/scheduler
    rm -rf tuned_log
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main $@
