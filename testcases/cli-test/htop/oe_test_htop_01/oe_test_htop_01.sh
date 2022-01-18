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

	# Interactive test

	# F1, Help
	expect <<EOF
		spawn htop
		send "h\r"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test F1 fails"

	# F2. Setup
	expect <<EOF
		spawn htop
		send "S"
		send "\27"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test F2 fails"

	# F3, Search
	expect <<EOF
		spawn htop
		send "/"
		send "htop\r"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test F3 fails"

	# F4, Filter
	expect <<EOF
		spawn htop
		send '\92'
		send "htop\r"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test F4 fails"

	# F5, Tree
	expect <<EOF
		spawn htop
		send "t"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test F5 fails"

	# F6, SortedBy
	expect <<EOF
		spawn htop
		send "<"
		send "\27"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test F6 fails"

	# F7, Nice -
	expect <<EOF
		spawn htop
		send "/"
		send "htop\r"
		send "\93"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test F7 fails"

	# F8, Nice +
	expect <<EOF
		spawn htop
		send "/"
		send "htop\r"
		send "\91"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test F8 fails"

	# F9, Kill
	expect <<EOF
		spawn htop
		send "/"
		send "htop\r"
		send "k"
		send "\27"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test F9 fails"

	# Other interactive options
	expect <<EOF
		spawn htop
		send "c"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test c fails"

	expect <<EOF
		spawn htop
		send "U"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test U fails"

	expect <<EOF
		spawn htop
		send "s"
		send "q"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test s fails"

	expect <<EOF
		spawn htop
		send "l"
		send "q"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test l fails"

	expect <<EOF
		spawn htop
		send "I"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test I fails"

	expect <<EOF
		spawn htop
		send "t"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test t fails"

	expect <<EOF
		spawn htop
		send "t"
		send "+"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test + fails"

	expect <<EOF
		spawn htop
		send "u"
		send "\27"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test u fails"

	expect <<EOF
		spawn htop
		send "M"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test M fails"

	expect <<EOF
		spawn htop
		send "P"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test P fails"

	expect <<EOF
		spawn htop
		send "T"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test T fails"

	expect <<EOF
		spawn htop
		send "K"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test K fails"

	expect <<EOF
		spawn htop
		send "H"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test H fails"

	expect <<EOF
		spawn htop
		send "p"
		send "q"
		expect eof
EOF
	CHECK_RESULT $? 0 0 "Interactive test p fails"

	LOG_INFO "End to run test."
}

function post_test() {
	LOG_INFO "Start to restore the test environment."

	DNF_REMOVE

	LOG_INFO "End to restore the test environment."
}

main "$@"

