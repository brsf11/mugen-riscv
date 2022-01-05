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
# @Desc      :   Test ldirectord.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL ldirectord
    cp /usr/share/doc/ldirectord/ldirectord.cf /etc/ha.d/
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution ldirectord.service
    systemctl start ldirectord.service
    sed -i 's\ExecStart=/usr/sbin/ldirectord\ExecStart=/usr/sbin/ldirectord -d\g' /usr/lib/systemd/system/ldirectord.service
    systemctl daemon-reload
    systemctl reload ldirectord.service
    CHECK_RESULT $? 0 0 "ldirectord.service reload failed"
    systemctl status ldirectord.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "ldirectord.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/ldirectord -d\ExecStart=/usr/sbin/ldirectord\g' /usr/lib/systemd/system/ldirectord.service
    systemctl daemon-reload
    systemctl reload ldirectord.service
    systemctl stop ldirectord.service
    rm -rf /etc/ha.d/ldirectord.cf
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
