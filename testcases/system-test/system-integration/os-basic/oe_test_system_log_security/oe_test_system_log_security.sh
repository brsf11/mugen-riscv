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
# @Desc      :   Support for the recording of information about system security
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
	LOG_INFO "Start to run test."
	sudo journalctl --unit crond.service -all >systemlog4
	logsize=$(ls -l systemlog4 | awk '{print $5}')
	[ "$logsize" -gt 0 ]
	CHECK_RESULT $?
	LOG_INFO "End to run test."
}

function post_test() {
	LOG_INFO "Start to restore the test environment."
	rm -rf systemlog4
	LOG_INFO "End to restore the test environment."
}

main $@
