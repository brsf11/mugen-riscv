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
# @Desc      :   Test postgresql.service restart
# #############################################

source "../../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL postgresql-server
    postgresql-setup --initdb
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution postgresql.service
    systemctl start postgresql.service
    sed -i 's\ExecStart=/usr/bin/postmaster\ExecStart=/usr/bin/postmaster -M\g' /usr/lib/systemd/system/postgresql.service
    systemctl daemon-reload
    systemctl reload postgresql.service
    CHECK_RESULT $? 0 0 "postgresql.service reload failed"
    systemctl status postgresql.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "postgresql.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/bin/postmaster -M\ExecStart=/usr/bin/postmaster\g' /usr/lib/systemd/system/postgresql.service
    systemctl daemon-reload
    systemctl reload postgresql.service
    systemctl stop postgresql.service
    DNF_REMOVE 1 "postgresql-server" 
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
