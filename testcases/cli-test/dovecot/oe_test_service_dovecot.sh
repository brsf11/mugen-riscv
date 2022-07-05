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
# @Desc      :   Test dovecot.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL dovecot
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution dovecot.service
    systemctl start dovecot.service
    sed -i 's\ExecStart=/usr/sbin/dovecot\ExecStart=/usr/sbin/dovecot -a\g' /usr/lib/systemd/system/dovecot.service
    systemctl daemon-reload
    systemctl reload dovecot.service
    CHECK_RESULT $? 0 0 "dovecot.service reload failed"
    systemctl status dovecot.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "dovecot.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/dovecot -a\ExecStart=/usr/sbin/dovecot\g' /usr/lib/systemd/system/dovecot.service
    systemctl daemon-reload
    systemctl reload dovecot.service
    systemctl stop dovecot.service
    rm -rf /etc/pki/dovecot/certs/dovecot.pem /etc/pki/dovecot/private/dovecot.pem
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
