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
# @Desc      :   Test strongswan.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL strongswan
    service=strongswan.service
    log_time=$(date '+%Y-%m-%d %T')
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    systemctl restart "${service}"
    CHECK_RESULT $? 0 0 "${service} restart failed"
    systemctl stop "${service}"
    CHECK_RESULT $? 0 0 "${service} stop failed"
    systemctl start "${service}"
    CHECK_RESULT $? 0 0 "${service} start failed"
    systemctl status "${service}" | grep "Active" | grep "active (running)"
    CHECK_RESULT $? 0 0 "${service} start failed"
    symlink_file=$(systemctl enable "${service}" 2>&1 | awk '{print $3}')
    find ${symlink_file}
    CHECK_RESULT $? 0 0 "${service} enable failed"
    systemctl disable "${service}"
    find ${symlink_file}
    CHECK_RESULT $? 0 1 "${service} disable failed"
    journalctl --since "${log_time}" -u "${service}" | grep -i "fail\|error" | grep -v -i "DEBUG\|INFO\|WARNING" | grep -v "/etc/strongswan/ipsec.d/triplets.dat" | grep -v "/etc/tnc_config"
    CHECK_RESULT $? 0 1 "There is an error message for the log of ${service}"
    test_reload strongswan.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop "${service}"
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"

