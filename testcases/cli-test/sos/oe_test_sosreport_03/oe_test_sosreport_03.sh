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
	sosreport --list-profiles
	CHECK_RESULT $?
	expect <<EOF
		log_file sos_log16
		spawn sosreport --log-size 10
		expect "" {send "\r"}
		expect ":" {send "log-size\r"}
		sleep 120
		expect eof
EOF
	grep "sosreport-localhost-log-size-$(date +%Y-%m-%d)" sos_log16 && test -f /var/tmp/sosreport-localhost-log-size-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	expect <<EOF
		log_file sos_log17
		spawn sosreport -n dnf,rpm,selinux,dovecot
		expect "" {send "\r"}
		expect ":" {send "skip-plugins\r"}
		sleep 120
		expect eof
EOF
	grep "sosreport-localhost-skip-plugins-$(date +%Y-%m-%d)" sos_log17 && test -f /var/tmp/sosreport-localhost-skip-plugins-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	expect <<EOF
		log_file sos_log18
		spawn sosreport --no-report 
		expect "" {send "\r"}
		expect ":" {send "no-report\r"}
		sleep 120
		expect eof
EOF
	grep "sosreport-localhost-no-report-$(date +%Y-%m-%d)" sos_log18 && test -f /var/tmp/sosreport-localhost-no-report-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	no_report_file=$(ls /var/tmp/sosreport-localhost-no-report-$(date +%Y-%m-%d)-*.tar.xz)
	tar -xvf ${no_report_file}
	test -f sosreport-localhost-no-report-$(date +%Y-%m-%d)-*/sos_reports/sos.html -a -f sosreport-localhost-no-report-$(date +%Y-%m-%d)-*/sos_reports/sos.txt -a -f sosreport-localhost-no-report-$(date +%Y-%m-%d)-*/sos_reports/sos.json
	CHECK_RESULT $? 1
	expect <<EOF
		log_file sos_log21
		spawn sosreport --note "testnote"
		expect "" {send "\r"}
		expect ":" {send "testnote\r"}
		sleep 120
		expect eof
EOF
	grep "sosreport-localhost-testnote-$(date +%Y-%m-%d)" sos_log21 && test -f /var/tmp/sosreport-localhost-testnote-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	sosreport -o dnf,rpm,selinux,dovecot --batch --label only-plugins >sos_log22
	CHECK_RESULT $?
	grep -E "4|dnf|rpm|selinux|dovecot|sosreport-localhost-only-plugins-$(date +%Y-%m-%d)-.*.tar.xz" sos_log22 && test -f /var/tmp/sosreport-localhost-only-plugins-$(date +%Y-%m-%d)-*.tar.xz
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
