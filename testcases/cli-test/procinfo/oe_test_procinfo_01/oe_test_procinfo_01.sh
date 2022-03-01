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

	local catch_result='
		expect "irq" {
			send "q";
			expect eof {
				catch wait result;
				exit [lindex $result 3]
			}
		}
'

	local unknown_cmd='
		"unknown command" {
			exit 1
		}
'

	expect <<EOF
		spawn procinfo -f
		expect "irq*" {
			$catch_result
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Option test -f fails"

	# Interactive test
	expect <<EOF
		spawn procinfo -f
		send "s"
		expect {
			$unknown_cmd
			"Bootup:*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key s fails"

	expect <<EOF
		spawn procinfo -f
		send "m"
		expect {
			$unknown_cmd
			"Modules:*" {
				expect "Modules:" {
					send "q"
					expect eof {
						catch wait result
						exit [lindex \$result 3]
					}
				}
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key m fails"

	expect <<EOF
		spawn procinfo -f
		send "a"
		expect {
			$unknown_cmd
			"Kernel Command Line:*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key a fails"

	expect <<EOF
		spawn procinfo -f
		send "r"
		expect {
			$unknown_cmd
			"buffers/cache*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key r fails"

	expect <<EOF
		spawn procinfo -f
		send "C"
		expect {
			$unknown_cmd
			"checkpoint set*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key C fails"

	expect <<EOF
		spawn procinfo -f
		send "R"
		expect {
			$unknown_cmd
			"checkpoint released*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key R fails"

	expect <<EOF
		spawn procinfo -f
		send "t"
		expect {
			$unknown_cmd
			"showing totals*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key t fails"

	expect <<EOF
		spawn procinfo -f
		send "d"
		expect {
			$unknown_cmd
			"showing diff*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key d fails"

	expect <<EOF
		spawn procinfo -f
		send "D"
		expect {
			$unknown_cmd
			"totals for memory*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key D fails"

	expect <<EOF
		spawn procinfo -f
		send "S"
		expect {
			$unknown_cmd
			"per second*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key S fails"

	expect <<EOF
		spawn procinfo -f
		send "i"
		expect {
			$unknown_cmd
			"full IRQ display*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key i fails"

	expect <<EOF
		spawn procinfo -f
		send "b"
		expect {
			$unknown_cmd
			"showing I/O in blocks*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key b fails"

	expect <<EOF
		spawn procinfo -f
		send "n"
		expect {
			$unknown_cmd
			"delay:" {
				send "1\n"
				expect "delay set to 1*" {
					$catch_result
				}
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key n fails"

	expect <<EOF
		spawn procinfo -f
		send " "
		expect {
			$unknown_cmd
			"hold*" {
				send "q"
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key <space> fails"

	expect <<EOF
		spawn procinfo -f
		send "\x0c"
		expect {
			$unknown_cmd
			"irq*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key ^L fails"

	expect <<EOF
		spawn procinfo -f
		send "?"
		expect {
			$unknown_cmd
			"? q*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key ? fails"

	expect <<EOF
		spawn procinfo -f
		send "h"
		expect {
			$unknown_cmd
			"? q*" {
				$catch_result
			}
		}
		exit 1
EOF
	CHECK_RESULT $? 0 0 "Interactive test key h fails"

	LOG_INFO "End to run test."
}

function post_test() {
	LOG_INFO "Start to restore the test environment."

	DNF_REMOVE

	LOG_INFO "End to restore the test environment."
}

main "$@"

