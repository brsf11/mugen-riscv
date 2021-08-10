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
# @Desc      :   Test crond.service restart
# #############################################

source "../common/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    test_execution crond.service
    systemctl start crond.service
    sed -i 's\ExecStart=/usr/sbin/crond -n\ExecStart=/usr/sbin/crond -n -c\g' /usr/lib/systemd/system/crond.service
    systemctl daemon-reload
    systemctl reload crond.service
    CHECK_RESULT $? 0 0 "crond.service reload failed"
    systemctl status crond.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "crond.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/crond -n -c\ExecStart=/usr/sbin/crond -n\g' /usr/lib/systemd/system/crond.service
    systemctl daemon-reload
    systemctl reload crond.service
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
