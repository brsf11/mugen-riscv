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
# @Desc      :   Test iptables.service restart
# #############################################

source "../common/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    test_execution iptables.service
    systemctl start iptables.service
    sed -i "s\iptables.init start\iptables.init condrestart\g" /usr/lib/systemd/system/iptables.service
    systemctl daemon-reload
    systemctl reload iptables.service
    CHECK_RESULT $? 0 0 "iptables.service reload failed"
    systemctl status iptables.service | grep "active (exited)"
    CHECK_RESULT $? 0 0 "iptables.service reload causes the service status to change"

    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\iptables.init condrestart\iptables.init start\g' /usr/lib/systemd/system/iptables.service
    systemctl daemon-reload
    systemctl reload iptables.service
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
