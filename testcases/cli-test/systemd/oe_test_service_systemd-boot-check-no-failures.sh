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
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Test systemd-boot-check-no-failures.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    REMOTE_REBOOT 2 60
    log_time=$(date '+%Y-%m-%d %T')
    service=systemd-boot-check-no-failures.service
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    P_SSH_CMD --node 2 --cmd "systemctl restart ${service}"
    SLEEP_WAIT 5
    P_SSH_CMD --node 2 --cmd "systemctl status ${service} | grep 'Active: active'"
    CHECK_RESULT $? 0 0 "${service} restart failed"
    P_SSH_CMD --node 2 --cmd "systemctl stop ${service}"
    SLEEP_WAIT 5
    P_SSH_CMD --node 2 --cmd "systemctl status ${service} | grep 'Active: inactive'"
    CHECK_RESULT $? 0 0 "${service} stop failed"
    P_SSH_CMD --node 2 --cmd "systemctl start ${service}"
    SLEEP_WAIT 5
    P_SSH_CMD --node 2 --cmd "systemctl status ${service} | grep 'Active: active'"
    CHECK_RESULT $? 0 0 "${service} start failed"
    P_SSH_CMD --node 2 --cmd "systemctl enable ${service}"
    P_SSH_CMD --node 2 --cmd "find /etc/systemd/system/boot-complete.target.requires/${service}"
    CHECK_RESULT $? 0 0 "${service} enable failed"
    P_SSH_CMD --node 2 --cmd "systemctl disable ${service}"
    P_SSH_CMD --node 2 --cmd "test ! -f /etc/systemd/system/boot-complete.target.requires/${service}"
    CHECK_RESULT $? 0 0 "${service} disable failed"
    P_SSH_CMD --node 2 --cmd "systemctl reload ${service} 2>&1 | grep 'Job type reload is not applicable'"
    CHECK_RESULT $? 0 0 "Job type reload is not applicable for unit ${service}"
    P_SSH_CMD --node 2 --cmd "systemctl status ${service} | grep 'Active: active'"
    CHECK_RESULT $? 0 0 "Check ${service} status failed"
    P_SSH_CMD --node 2 --cmd "test 0 -eq \$(journalctl --since '${log_time}' -u ${service} | grep -v 'Health check: no failed units' |
        grep -v '${service}: Succeeded' | grep -v 'Check if Any System Units Failed' | grep -i -c 'fail\|error')"
    CHECK_RESULT $? 0 0 "There is an error message for the log of ${service}"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    P_SSH_CMD --node 2 --cmd "systemctl stop ${service}"
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
