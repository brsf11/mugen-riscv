#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

####################################
#@Author    	:   jiangsonglin2
#@Contact   	:   songlin@isrc.iscas.ac.cn
#@Date      	:   2022-02-22 10:18:00
#@License       :   Mulan PSL v2
#@Desc      	:   Test Command procinfo
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
	LOG_INFO "Start to prepare the test environment."

	DNF_INSTALL "procinfo"

	LOG_INFO "End to prepare the test environment."
}

function run_test() {
	LOG_INFO "Start to run test."

	local test_full_screen='
		expect "irq*" {
			expect "irq" {
				send "q";
				expect eof {
					catch wait result;
					exit [lindex $result 3]
				}
			}
		}
		exit 1
'

	procinfo | grep "^irq"
	CHECK_RESULT $? 0 0 "No option test fails"

	# Options test
	procinfo -b | grep "^Linux\|^Bootup:\|^uptime:"
	CHECK_RESULT $? 0 0 "Option test -b fails"

	procinfo -s | grep "^Memory:"
	CHECK_RESULT $? 0 0 "Option test -s fails"

	procinfo -m | grep "^Modules:\|Devices:\|^File Systems:"
	CHECK_RESULT $? 0 0 "Option test -m fails"

	procinfo -a | grep "^Kernel Command Line:"
	CHECK_RESULT $? 0 0 "Option test -a fails"

	procinfo -i | grep -E ":[[:blank:]]+0[[:blank:]]"
	CHECK_RESULT $? 0 0 "Option test -i fails"

	expect <<EOF
		spawn procinfo -n1
		$test_full_screen
EOF
	CHECK_RESULT $? 0 0 "Option test -nN fails"

	expect <<EOF
		spawn procinfo -d
		$test_full_screen
EOF
	CHECK_RESULT $? 0 0 "Option test -d fails"

	expect <<EOF
		spawn procinfo -D
		$test_full_screen
EOF
	CHECK_RESULT $? 0 0 "Option test -D fails"

	expect <<EOF
		spawn procinfo -SD
		$test_full_screen
EOF
	CHECK_RESULT $? 0 0 "Option test -S fails"

	procinfo -r | grep -E "^\-\/\+ buffers:"
	CHECK_RESULT $? 0 0 "Option test -r fails"

	procinfo -F/dev/stdout | grep "^irq"
	CHECK_RESULT $? 0 0 "Option test -Ffile fails"

	! procinfo -v 2>&1 | grep "invalid option" && procinfo -v | grep "version"
	CHECK_RESULT $? 0 0 "Option test -v fails"

	! procinfo -h 2>&1 | grep "invalid option" && procinfo -h | grep "usage: procinfo"
	CHECK_RESULT $? 0 0 "Option test -h fails"

	LOG_INFO "End to run test."
}

function post_test() {
	LOG_INFO "Start to restore the test environment."

	DNF_REMOVE

	LOG_INFO "End to restore the test environment."
}

main "$@"

