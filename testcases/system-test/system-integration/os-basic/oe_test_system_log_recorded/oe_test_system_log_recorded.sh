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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   The system log is recorded in a fixed log file
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
	LOG_INFO "Start executing testcase."
	grep Storage /etc/systemd/journald.conf | grep -E "Storage=auto|Storage=persistent"
	CHECK_RESULT $?
	folder=$(ls /run/log/journal/)
	cp -r /run/log/journal/$folder /run/log/journal/${folder}bak
	rm -rf /run/log/journal/$folder
	systemctl restart systemd-journald.service
	if [ ! -d "/run/log/journal/$folder" ]; then
		((exec_result++))
		cp -r /run/log/journal/${folder}bak /run/log/journal/${folder}
	fi
	CHECK_RESULT $(ls -la /run/log/journal/${folder} | grep "^-" | grep "journal" | wc -l) 1
	sudo journalctl --file /run/log/journal/${folder}/system.journal >systemlog1
	logsize=$(ls -l systemlog1 | awk '{print $5}')
	test $logsize -gt 0
	CHECK_RESULT $?
	LOG_INFO "End of testcase execution."
}

function post_test() {
	LOG_INFO "start environment cleanup."
	rm -rf /run/log/journal/${folder}bak systemlog1
	LOG_INFO "Finish environment cleanup."
}

main $@
