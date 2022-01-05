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
# @Desc      :   View information about recent system reboots
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
	LOG_INFO "Start to run test."
	SSH_CMD "reboot" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
	REMOTE_REBOOT_WAIT 2 15
	SSH_CMD "reboot" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
	REMOTE_REBOOT_WAIT 2 15
	SSH_CMD "reboot" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
	REMOTE_REBOOT_WAIT 2 15
	SSH_CMD "last reboot > /tmp/rebootlog2" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
	CHECK_RESULT $?
	SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/tmp/rebootlog2 . ${NODE2_PASSWORD}
	CHECK_RESULT $?
	num_user=$(cat rebootlog2 | grep 'reboot' | wc -l)
	test $num_user -ge 3
	CHECK_RESULT $?
	LOG_INFO "End to run test."
}

function post_test() {
	LOG_INFO "Start to restore the test environment."
	rm -rf rebootlog2
	LOG_INFO "End to restore the test environment."
}

main $@
