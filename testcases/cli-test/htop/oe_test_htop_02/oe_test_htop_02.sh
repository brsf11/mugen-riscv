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
#@Author    	:   Wuyifei
#@Contact   	:   wyffeiwhe@gmail.com
#@Date      	:   2022-01-4 21:32:00
#@License       :   Mulan PSL v2
#@Desc      	:   verification htop‘s command
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
	LOG_INFO "Start to prepare the test environment."

	DNF_INSTALL "htop"

	LOG_INFO "End to prepare the test environment."
}

function run_test() {
	LOG_INFO "Start to run test."

	# Options test
	expect <<EOF
		spawn htop -d 12
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Option test -d fails"

	expect <<EOF
		spawn htop -C
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Option test -C fails"

	expect <<EOF
		spawn htop -p 1
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Option test -p fails"

	expect <<EOF
		spawn htop -s PID
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Option test -s fails"

	expect <<EOF
		spawn htop -u root
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Option test -u fails"

	expect <<EOF
		spawn htop -U
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Option test -U fails"

	expect <<EOF
		spawn htop -t
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Option test -t fails"

	expect <<EOF
		spawn htop -m
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Option test -m fails"

	htop -v | grep "htop"
	CHECK_RESULT $? 0 0 "Option test -v fails"

	htop -h | grep "See 'man htop' for more information"
	CHECK_RESULT $? 0 0 "Option test -h fails"

	LOG_INFO "End to run test."
}

function post_test() {
	LOG_INFO "Start to restore the test environment."

	DNF_REMOVE

	LOG_INFO "End to restore the test environment."
}

main "$@"
