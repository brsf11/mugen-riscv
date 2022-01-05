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
# @Desc      :   Test nginx.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL nginx
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution nginx.service
    systemctl start nginx.service
    sed -i 's\ExecStart=/usr/sbin/nginx\ExecStart=/usr/sbin/nginx -q\g' /usr/lib/systemd/system/nginx.service
    systemctl daemon-reload
    systemctl reload nginx.service
    CHECK_RESULT $? 0 0 "nginx.service reload failed"
    systemctl status nginx.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "nginx.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/nginx -q\ExecStart=/usr/sbin/nginx\g' /usr/lib/systemd/system/nginx.service
    systemctl daemon-reload
    systemctl reload nginx.service
    systemctl stop nginx.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
