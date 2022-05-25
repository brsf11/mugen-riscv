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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @modify    :   wangxiaoya@qq.com
# @Date      :   2022/05/12
# @License   :   Mulan PSL v2
# @Desc      :   Identify SELinux rejects
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    default_selinux_status=$(getenforce)
    [ "${default_selinux_status}" == "Enforcing" ] || setenforce 1
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    ausearch -m AVC,USER_AVC,SELINUX_ERR,USER_SELINUX_ERR -ts recent >log1 2>&1
    grep 'no matches' log1
    if [ $? -eq 0 ]; then
        journalctl -t setroubleshoot > log2
        test -s log2
        CHECK_RESULT $?
        dmesg | grep -i -e type=1403 -e type=1404 > log3
        test -s log3
        CHECK_RESULT $?
        semodule -B
        SLEEP_WAIT 20
        ausearch -m AVC,USER_AVC,SELINUX_ERR,USER_SELINUX_ERR -ts recent >log4 2>&1
        grep 'no matches' log4
        CHECK_RESULT $? 0 1
    fi
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    if [ "$default_selinux_status" == "Enforcing" ]; then
        setenforce 1
    else
        setenforce 0
    fi
    rm -rf log*
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
