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
# @Desc      :   Test squid.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL squid
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution squid.service
    systemctl start squid.service
    sed -i 's\ExecStart=/usr/sbin/squid\ExecStart=/usr/sbin/squid -X\g' /usr/lib/systemd/system/squid.service
    systemctl daemon-reload
    systemctl reload squid.service
    CHECK_RESULT $? 0 0 "squid.service reload failed"
    systemctl status squid.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "squid.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/squid -X\ExecStart=/usr/sbin/squid\g' /usr/lib/systemd/system/squid.service
    systemctl daemon-reload
    systemctl reload squid.service
    systemctl stop squid.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}


main "$@"
