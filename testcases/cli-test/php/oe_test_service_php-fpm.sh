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
# @Desc      :   Test php-fpm.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL php-fpm
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution php-fpm.service
    systemctl start php-fpm.service
    sed -i 's\ExecStart=/usr/sbin/php-fpm --nodaemonize\ExecStart=/usr/sbin/php-fpm\g' /usr/lib/systemd/system/php-fpm.service
    systemctl daemon-reload
    systemctl reload php-fpm.service
    CHECK_RESULT $? 0 0 "php-fpm.service reload failed"
    systemctl status php-fpm.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "php-fpm.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/php-fpm\ExecStart=/usr/sbin/php-fpm --nodaemonize\g' /usr/lib/systemd/system/php-fpm.service
    systemctl daemon-reload
    systemctl reload php-fpm.service
    systemctl stop php-fpm.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
