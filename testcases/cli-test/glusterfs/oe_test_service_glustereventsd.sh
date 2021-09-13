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
# @Desc      :   Test glustereventsd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL glusterfs
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution glustereventsd.service
    cur_status=$(systemctl status glustereventsd.service | grep Active | awk '{print $2}')
    test "${cur_status}"!="active" && systemctl start glustereventsd.service
    SLEEP_WAIT 10
    sed -i 's\/usr/sbin/glustereventsd --pid-file /var/run/glustereventsd.pid\/usr/sbin/glustereventsd\g' /usr/lib/systemd/system/glustereventsd.service
    systemctl daemon-reload
    systemctl reload glustereventsd.service
    CHECK_RESULT $? 0 0 "glustereventsd.service reload failed"
    systemctl status glustereventsd.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "glustereventsd.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\/usr/sbin/glustereventsd\/usr/sbin/glustereventsd --pid-file /var/run/glustereventsd.pid\g' /usr/lib/systemd/system/glustereventsd.service
    systemctl daemon-reload
    systemctl reload glustereventsd.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
