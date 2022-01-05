#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Desc      :   Test openEuler-security.service restart
# #############################################

source "../common/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    service=openEuler-security.service
    status='inactive (dead)'
    systemctl status "${service}" | grep "Active" | grep -v "${status}"
    CHECK_RESULT $? 0 1 "There is an error for the status of ${service}"
    symlink_file=$(systemctl enable "${service}" 2>&1 | awk '{print $3}')
    find ${symlink_file}
    CHECK_RESULT $? 0 0 "${service} enable failed"
    systemctl disable "${service}"
    find ${symlink_file}
    CHECK_RESULT $? 0 1 "${service} disable failed"
    journalctl -u "${service}" | grep -i "fail\|error" | grep -v "net.ipv4.icmp_ignore_bogus_error_responses"
    CHECK_RESULT $? 0 1 "There is an error message for the log of ${service}"
    test_reload openEuler-security.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop "${service}"
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
