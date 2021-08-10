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
# @Desc      :   Test dracut-initqueue.service restart
# #############################################

source "../common/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    service=dracut-initqueue.service
    status='inactive (dead)'
    systemctl status "${service}" | grep "Active" | grep -v "${status}"
    CHECK_RESULT $? 0 1 "There is an error for the status of ${service}"
    state=$(systemctl is-enabled "${service}")
    if [ "${state}" == "enabled" ]; then
        symlink_file=$(systemctl disable "${service}" 2>&1 | awk '{print $2}' | awk '{print substr($0,1,length($0)-1)}')
        find ${symlink_file}
        CHECK_RESULT $? 0 1 "${service} disable failed"
        systemctl enable "${service}"
        find ${symlink_file}
        CHECK_RESULT $? 0 0 "${service} enable failed"
    elif [ "${state}" == "disable" ]; then
        symlink_file=$(systemctl enable "${service}" 2>&1 | awk '{print $3}')
        find ${symlink_file}
        CHECK_RESULT $? 0 0 "${service} enable failed"
        systemctl disable "${service}"
        find ${symlink_file}
        CHECK_RESULT $? 0 1 "${service} disable failed"
    elif [ "${state}" == "masked" ]; then
        LOG_INFO "Unit is masked, ignoring."
    elif [ "${state}" == "static" ]; then
        LOG_INFO "The unit files have no installation config. This means they are not meant to be enabled using systemctl."
    else
        LOG_INFO "Unit is indirect, ignoring."
    fi
    journalctl -u "${service}" | grep -i "fail\|error" | grep -v "ignorelockingfailure"
    CHECK_RESULT $? 0 1 "There is an error message for the log of ${service}"
    LOG_INFO "Finish test!"
}

main "$@"
