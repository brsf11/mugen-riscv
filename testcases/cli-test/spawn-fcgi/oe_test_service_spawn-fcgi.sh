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
# @Date      :   2021/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Test spawn-fcgi.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "spawn-fcgi php-cgi nginx"
    echo 'SOCKET=/var/run/fcgiwrap.sock
FCGI_SOCKET=/var/run/fcgiwrap.sock
FCGI_PROGRAM=/usr/bin/php-cgi
FCGI_USER=nginx
FCGI_GROUP=nginx
FCGI_EXTRA_OPTIONS="-M 0777"
OPTIONS="-u $FCGI_USER -g $FCGI_GROUP -s $FCGI_SOCKET -S $FCGI_EXTRA_OPTIONS -F 1 -P /var/run/spawn-fcgi.pid -- $FCGI_PROGRAM"' >/etc/sysconfig/spawn-fcgi
    service=spawn-fcgi.service
    log_time=$(date '+%Y-%m-%d %T')
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_restart ${service}
    systemctl enable ${service} 2>&1 | grep "spawn-fcgi.service is not a native service"
    CHECK_RESULT $? 0 0 "${service} enable failed"
    systemctl disable "${service}" 2>&1 | grep "spawn-fcgi.service is not a native service"
    CHECK_RESULT $? 0 0 "${service} disable failed"
    journalctl --since "${log_time}" -u "${service}" | grep -i "fail\|error" | grep -v -i "DEBUG\|INFO\|WARNING"
    CHECK_RESULT $? 0 1 "There is an error message for the log of ${service}"
    first_pid=$(pgrep -f php-cgi)
    systemctl reload "${service}"
    test ${first_pid} -ne "$(pgrep -f php-cgi)"
    CHECK_RESULT $? 0 0 "${service} reload failed"
    systemctl status "${service}" | grep "Active: active"
    CHECK_RESULT $? 0 0 "${service} reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop ${service}
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
