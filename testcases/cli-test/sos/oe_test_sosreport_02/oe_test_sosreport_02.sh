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
	expect <<EOF
		log_file sos_log9
		spawn sosreport --debug
		expect "" {send "\r"}
		expect ":" {send "debug\r"}
		sleep 120
		expect eof
EOF
	grep "sosreport-localhost-debug-$(date +%Y-%m-%d)" sos_log9 && test -f /var/tmp/sosreport-localhost-debug-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	expect <<EOF
		log_file sos_log10
		spawn sosreport --desc "test description content" 
		expect "" {send "\r"}
		expect ":" {send "desc\r"}
		sleep 120
		expect eof
EOF
	grep "sosreport-localhost-desc-$(date +%Y-%m-%d)" sos_log10 && test -f /var/tmp/sosreport-localhost-desc-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	expect <<EOF
		log_file sos_log12
		spawn sosreport --experimental
		expect "" {send "\r"}
		expect ":" {send "experimental\r"}
		sleep 120
		expect eof
EOF
	grep "sosreport-localhost-experimental-$(date +%Y-%m-%d)" sos_log12 && test -f /var/tmp/sosreport-localhost-experimental-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	expect <<EOF
		log_file sos_log13
		spawn sosreport -e dnf,rpm,selinux,dovecot
		expect "" {send "\r"}
		expect ":" {send "enable-plugins\r"}
		sleep 120
		expect eof
EOF
	grep "sosreport-localhost-enable-plugins-$(date +%Y-%m-%d)" sos_log13 && test -f /var/tmp/sosreport-localhost-enable-plugins-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	sosreport -l | grep -E "on|off|inactive"
	CHECK_RESULT $?
	expect <<EOF
		log_file sos_log14
		spawn sosreport -k dnf.history
		expect "" {send "\r"}
		expect ":" {send "plugin-option\r"}
		sleep 180
		expect eof
EOF
	grep "sosreport-localhost-plugin-option-$(date +%Y-%m-%d)" sos_log14 && test -f /var/tmp/sosreport-localhost-plugin-option-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	expect <<EOF
		log_file sos_log15
		spawn sosreport --label test-label
		expect "" {send "\r"}
		expect ":" {send "\r"}
		sleep 120
		expect eof
EOF
	grep "sosreport-localhost-test-label-$(date +%Y-%m-%d)" sos_log15 && test -f /var/tmp/sosreport-localhost-test-label-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	sosreport --list-presets
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
