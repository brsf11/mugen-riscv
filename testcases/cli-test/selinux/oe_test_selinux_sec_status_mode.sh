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
# @Desc      :   selinux status and mode
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    default_selinux_status=$(getenforce)
    setenforce 1
    DNF_INSTALL "setroubleshoot-server"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    getenforce | grep "Enforcing"
    CHECK_RESULT $?
    setenforce 0
    getenforce | grep "Permissive"
    CHECK_RESULT $?
    setenforce 1
    getenforce | grep "Enforcing"
    CHECK_RESULT $?
    semanage permissive -a httpd_t
    CHECK_RESULT $?
    semanage permissive -d httpd_t
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    if [ "$default_selinux_status" == "Enforcing" ]; then
        setenforce 1
    else
        setenforce 0
    fi
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
