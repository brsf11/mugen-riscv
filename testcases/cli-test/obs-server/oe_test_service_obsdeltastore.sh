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
# @Desc      :   Test obsdeltastore.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    flag=false
    if [ $(getenforce | grep Enforcing) ]; then
        setenforce 0
        flag=true
    fi
    DNF_INSTALL obs-server
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution obsdeltastore.service
    systemctl start obsdeltastore.service
    sed -i 's\ExecStart=/usr/lib/obs/server/bs_deltastore --logfile deltastore.log\ExecStart=/usr/lib/obs/server/bs_deltastore\g' /usr/lib/systemd/system/obsdeltastore.service
    systemctl daemon-reload
    systemctl reload obsdeltastore.service
    CHECK_RESULT $? 0 0 "obsdeltastore.service  reload failed"
    systemctl status obsdeltastore.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "obsdeltastore.service  reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/lib/obs/server/bs_deltastore\ExecStart=/usr/lib/obs/server/bs_deltastore --logfile deltastore.log\g' /usr/lib/systemd/system/obsdeltastore.service
    systemctl daemon-reload
    systemctl reload obsdeltastore.service
    systemctl stop obsdeltastore.service
    DNF_REMOVE
    if [ ${flag} = 'true' ]; then
        setenforce 1
    fi
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
