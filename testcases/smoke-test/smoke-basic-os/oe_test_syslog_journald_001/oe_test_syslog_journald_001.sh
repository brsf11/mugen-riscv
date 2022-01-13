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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-6-19
# @License   :   Mulan PSL v2
# @Desc      :   The system log is recorded in a fixed log file
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function config_params() {
	LOG_INFO "Start to config params of the case."
	if ls /run/log/journal/*; then
		path=run
	else
		path=var
	fi
	folder=$(ls /${path}/log/journal/ | head -n 1)
	LOG_INFO "End to config params of the case."
}
function run_test() {
	LOG_INFO "Start to run test."
	grep Storage /etc/systemd/journald.conf | egrep "Storage=auto|Storage=persistent"
	CHECK_RESULT $?
	cp -r /${path}/log/journal/"${folder}" /${path}/log/journal/"${folder}"bak
	rm -rf /${path}/log/journal/"${folder}"
	systemctl restart systemd-journald.service
	if [ ! -d "/${path}/log/journal/$folder" ]; then
		CHECK_RESULT 0 1
		cp -r /${path}/log/journal/"${folder}"bak /${path}/log/journal/"${folder}"
	fi
	check_file=$(ls -la /${path}/log/journal/"${folder}" | grep "^-" | grep "journal" | wc -l)
	CHECK_RESULT "${check_file}" 1
	journalctl --file /${path}/log/journal/"${folder}"/system.journal >systemlog1
	logsize=$(grep -v ' No entries ' systemlog1 | wc -l)
	test $((logsize)) -gt 1
	CHECK_RESULT $?
	LOG_INFO "End to run test."
}

function post_test() {
	LOG_INFO "Start to restore the test environment."
	rm -rf /${path}/log/journal/"${folder}"bak systemlog1
	LOG_INFO "End to restore the test environment."
}

main $@
