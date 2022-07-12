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
	VERSION_ID=$(grep "VERSION_ID" /etc/os-release | awk -F '\"' '{print$2}')
	LOG_INFO "Finish preparing the test environment."
}

function run_test() {
	LOG_INFO "Start to run test."
	sosreport -s "/tmp" >runlog 2>&1
	CHECK_RESULT $? 1
	grep "Could not obtain installed package list" runlog
	CHECK_RESULT $?
	sosreport -s "/" --batch --label sysroot >sos_log25
	CHECK_RESULT $?
	grep "sosreport-localhost-sysroot-$(date +%Y-%m-%d)" sos_log25 && test -f /var/tmp/sosreport-localhost-sysroot-$(date +%Y-%m-%d)-*.tar.xz
	CHECK_RESULT $?
	if [ $VERSION_ID != "22.03" ]; then
		sosreport --batch --ticket-number 666
		CHECK_RESULT $?
		test -f /var/tmp/sosreport-localhost-666-$(date +%Y-%m-%d)-*.tar.xz
		CHECK_RESULT $?
		mkdir temp
		CHECK_RESULT $?
		sosreport --batch --tmp-dir temp --ticket-number temp
		CHECK_RESULT $?
		test -f temp/sosreport-localhost-temp-$(date +%Y-%m-%d)-*.tar.xz
		CHECK_RESULT $?
		sosreport --batch --tmp-dir temp -v --ticket-number verbose >sos_log26
		CHECK_RESULT $?
		grep -E "adding|collecting|sosreport-localhost-verbose-$(date +%Y-%m-%d)-.*.tar.xz" sos_log26 && test -f temp/sosreport-localhost-verbose-$(date +%Y-%m-%d)-*.tar.xz
		CHECK_RESULT $?
		sosreport --batch --verify --tmp-dir temp --ticket-number verify
		CHECK_RESULT $?
		test -f temp/sosreport-localhost-verify-$(date +%Y-%m-%d)-*.tar.xz
		CHECK_RESULT $?
		sosreport -z gzip --batch --tmp-dir temp --ticket-number gzipForm
		CHECK_RESULT $?
		test -f temp/sosreport-localhost-gzipForm-$(date +%Y-%m-%d)-*.tar.gz
		CHECK_RESULT $?
		sosreport --threads 6 --batch --tmp-dir temp --ticket-number threads
		CHECK_RESULT $?
		test -f temp/sosreport-localhost-threads-$(date +%Y-%m-%d)-*.tar.xz
		CHECK_RESULT $?
	else
		LOG_INFO "Obsolete version command"
	fi

	LOG_INFO "End of the test."
}

function post_test() {
	LOG_INFO "Start to restore the test environment."
	rm -rf $(ls | grep -v ".sh") /var/tmp/sos*
	DNF_REMOVE
	LOG_INFO "Finish restoring the test environment."
}

main $@
