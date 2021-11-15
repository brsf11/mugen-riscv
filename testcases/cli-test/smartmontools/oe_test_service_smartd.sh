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
# @Desc      :   Test smartd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL smartmontools
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution smartd.service
    systemctl start smartd.service
    sed -i 's\ExecStart=/usr/sbin/smartd\ExecStart=/usr/sbin/smartd -d\g' /usr/lib/systemd/system/smartd.service
    systemctl daemon-reload
    systemctl reload smartd.service
    CHECK_RESULT $? 0 0 "smartd.service reload failed"
    systemctl status smartd.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "smartd.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/smartd -d\ExecStart=/usr/sbin/smartd\g' /usr/lib/systemd/system/smartd.service
    systemctl daemon-reload
    systemctl reload smartd.service
    systemctl stop smartd.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
