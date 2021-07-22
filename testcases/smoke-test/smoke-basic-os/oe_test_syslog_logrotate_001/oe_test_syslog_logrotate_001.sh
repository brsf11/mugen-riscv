#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-6-18
# @License   :   Mulan PSL v2
# @Desc      :   test syslog dump-logrotate
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
	LOG_INFO "Start to run test."
	ls /var/log/messages
	CHECK_RESULT $?
	rm -rf /var/log/messages-*.gz
	mv /etc/logrotate.d/rsyslog /etc/logrotate.d/rsyslog_bak
	cat >/etc/logrotate.d/rsyslog <<eof
/var/log/messages
{
    dateext
    rotate 30
    size +4096k
    compress
    dateformat -%Y%m%d%s
    sharedscripts
    postrotate
        /usr/bin/systemctl kill -s HUP rsyslog.service >/dev/null 2>&1 || true
    endscript
}
eof
	logrotate -f /etc/logrotate.d/rsyslog
	CHECK_RESULT $?
	ls /var/log/messages-*.gz
	CHECK_RESULT $?
	LOG_INFO "End to run test."
}

function post_test() {
	LOG_INFO "Start to restore the test environment."
	rm -rf /etc/logrotate.d/rsyslog
	mv /etc/logrotate.d/rsyslog_bak /etc/logrotate.d/rsyslog
	LOG_INFO "End to restore the test environment."
}

main $@
