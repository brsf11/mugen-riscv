#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2021/01/04
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of sosreport command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
	LOG_INFO "Start to prepare the test environment."
	DNF_INSTALL "sos tar"
	LOG_INFO "Finish preparing the test environment."
}

function run_test() {
	LOG_INFO "Start to run test."
	sosreport -h | grep -E "usage: sosreport \[options\]|-"
	CHECK_RESULT $?
	expect <<EOF
        log_file sos_log1
        spawn sosreport -a
        expect "" {send "\r"}
        expect ":" {send "001\r"}
        sleep 500
        expect eof
EOF
	grep "sosreport-localhost-001" sos_log1 && test -f /var/tmp/sosreport-localhost-001-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	expect <<EOF
        log_file sos_log2
        spawn sosreport --all-logs
        expect "" {send "\r"}
        expect ":" {send "002\r"}
        sleep 150
        expect eof
EOF
	grep "sosreport-localhost-002" sos_log2 && test -f /var/tmp/sosreport-localhost-002-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	expect <<EOF
        log_file sos_log3
        spawn sosreport --all-logs
        expect "" {send "\r"}
        expect ":" {send "003\r"}
        sleep 120
        expect eof
EOF
	grep "sosreport-localhost-003" sos_log3 && test -f /var/tmp/sosreport-localhost-003-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	sosreport --batch | tee sos_log4
	CHECK_RESULT $?
	grep "sosreport-localhost-$(date +%Y-%m-%d)" sos_log4 && test -f /var/tmp/sosreport-localhost-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	expect <<EOF
        log_file sos_log5
        spawn sosreport  --build
        expect "" {send "\r"}
        expect ":" {send "build\r"}
        sleep 120
        expect eof
EOF
	grep "sosreport-localhost-build-$(date +%Y-%m-%d)" sos_log5 && test -d /var/tmp/sosreport-localhost-build-$(date +%Y-%m-%d)-*
	CHECK_RESULT $?
	expect <<EOF
        log_file sos_log6
        spawn sosreport  --case-id test 
        expect "" {send "\r"}
		expect "" {send "\r"}
        sleep 120
        expect eof
EOF
	grep "sosreport-localhost-test-$(date +%Y-%m-%d)" sos_log6 && test -f /var/tmp/sosreport-localhost-test-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	expect <<EOF
        log_file sos_log7
        spawn sosreport  -c never
        expect "" {send "\r"}
		expect ":" {send "never\r"}
        sleep 120
        expect eof
EOF
	grep "sosreport-localhost-never-$(date +%Y-%m-%d)" sos_log7 && test -f /var/tmp/sosreport-localhost-never-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	expect <<EOF
		log_file sos_log8
		spawn sosreport --config-file /etc/sos.conf
		expect "" {send "\r"}
		expect ":" {send "config\r"}
		sleep 120
		expect eof
EOF
	grep "sosreport-localhost-config-$(date +%Y-%m-%d)" sos_log8 && test -f /var/tmp/sosreport-localhost-config-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	LOG_INFO "End of the test."
}

function post_test() {
	LOG_INFO "Start to restore the test environment."
	rm -rf $(ls | grep -v ".sh") /var/tmp/sos*
	DNF_REMOVE
	LOG_INFO "Finish restoring the test environment."
}

main $@
