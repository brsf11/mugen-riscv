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
# @Desc      :   Test system-update-cleanup.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    service=system-update-cleanup.service
    log_time=$(date '+%Y-%m-%d %T')
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    P_SSH_CMD --node 2 --cmd "touch /system-update;systemctl restart system-update-cleanup.service"
    REMOTE_REBOOT_WAIT 2 60
    P_SSH_CMD --node 2 --cmd "test ! -f /system-update"
    CHECK_RESULT $? 0 0 "${service} restart failed"
    P_SSH_CMD --node 2 --cmd "systemctl stop system-update-cleanup.service"
    CHECK_RESULT $? 0 0 "${service} stop failed"
    SLEEP_WAIT 5
    P_SSH_CMD --node 2 --cmd "systemctl status system-update-cleanup.service | grep 'Active: inactive'"
    CHECK_RESULT $? 0 0 "${service} stop failed"
    P_SSH_CMD --node 2 --cmd "systemctl is-enabled system-update-cleanup.service | grep 'static'"
    CHECK_RESULT $? 0 0 "The unit files is not static"
    P_SSH_CMD --node 2 --cmd "touch /system-update;systemctl start system-update-cleanup.service"
    REMOTE_REBOOT_WAIT 2 60
    P_SSH_CMD --node 2 --cmd "test ! -f /system-update"
    CHECK_RESULT $? 0 0 "${service} start failed"
    P_SSH_CMD --node 2 --cmd "test 0 -eq \$(journalctl --since '${log_time}' -u system-update-cleanup.service | grep -i -c 'fail\|error')"
    CHECK_RESULT $? 0 0 "There is an error message for the log of system-update-cleanup.service"
    LOG_INFO "Finish test!"
}

main "$@"
