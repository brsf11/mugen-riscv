#!/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/11/03
# @License   :   Mulan PSL v2
# @Desc      :   common function library for service restart of the base images
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function test_execution() {
    service=$1
    log_time=$(date '+%Y-%m-%d %T')
    test_restart "${service}"
    test_enabled "${service}"
    journalctl --since "${log_time}" -u "${service}" | grep -i "fail\|error" | grep -v -i "DEBUG\|INFO\|WARNING"
    CHECK_RESULT $? 0 1 "There is an error message for the log of ${service}"
}

function test_restart() {
    service=$1
    systemctl restart "${service}"
    CHECK_RESULT $? 0 0 "${service} restart failed"
    SLEEP_WAIT 5
    systemctl status "${service}" | grep "Active: active"
    CHECK_RESULT $? 0 0 "${service} restart failed"
    systemctl stop "${service}"
    CHECK_RESULT $? 0 0 "${service} stop failed"
    SLEEP_WAIT 5
    systemctl status "${service}" | grep "Active: inactive"
    CHECK_RESULT $? 0 0 "${service} stop failed"
    systemctl start "${service}"
    CHECK_RESULT $? 0 0 "${service} start failed"
    systemctl status "${service}" | grep "Active: active"
    CHECK_RESULT $? 0 0 "${service} start failed"
}

function test_oneshot() {
    service=$1
    status=$2
    systemctl status "${service}" | grep "Active" | grep -v "${status}"
    CHECK_RESULT $? 0 1 "There is an error for the status of ${service}"
    test_enabled "${service}"
    journalctl -u "${service}" | grep -i "fail\|error" | grep -v -i "DEBUG\|INFO\|WARNING"
    CHECK_RESULT $? 0 1 "There is an error message for the log of ${service}"
}

test_enabled() {
    service=$1
    state=$(systemctl is-enabled "${service}")
    if [ "${state}" == "enabled" ]; then
        symlink_file=$(systemctl disable "${service}" 2>&1 | awk '{print $2}' | awk '{print substr($0,1,length($0)-1)}')
        find ${symlink_file}
        CHECK_RESULT $? 0 1 "${service} disable failed"
        systemctl enable "${service}"
        find ${symlink_file}
        CHECK_RESULT $? 0 0 "${service} enable failed"
    elif [ "${state}" == "disabled" ]; then
        symlink_file=$(systemctl enable "${service}" 2>&1 | awk '{print $3}')
        find ${symlink_file}
        CHECK_RESULT $? 0 0 "${service} enable failed"
        systemctl disable "${service}"
        find ${symlink_file}
        CHECK_RESULT $? 0 1 "${service} disable failed"
    elif [ "${state}" == "masked" ]; then
        LOG_INFO "Unit is masked, ignoring."
    elif [ "${state}" == "static" ]; then
        LOG_INFO "The unit files have no installation config,This means they are not meant to be enabled using systemctl."
    else
        LOG_INFO "Unit is indirect, ignoring."
    fi
}

function test_reload() {
    service=$1
    systemctl start "${service}"
    systemctl reload "${service}" 2>&1 | grep "Job type reload is not applicable"
    CHECK_RESULT $? 0 0 "Job type reload is not applicable for unit ${service}"
    if ! systemctl status "${service}" | grep "Active: active"; then
        if systemctl status "${service}" | grep "inactive (dead)"; then
            systemctl status "${service}" | grep "Condition check" | grep "skip"
            CHECK_RESULT $? 0 0 "${service} reload causes the service status to change"
        else
            return 1
        fi
    fi
}
