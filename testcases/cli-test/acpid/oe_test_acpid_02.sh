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
#@Author    	:   zhangyili2
#@Contact   	:   yili@isrc.iscas.ac.cn
#@Date      	:   2022-05-19 09:39:43
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test for acpid-option
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    DNF_INSTALL "acpid"

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    ! acpid --version | grep "invalid option" && acpid --version | grep "acpid-[0-9]*.*"
    CHECK_RESULT $? 0 0 "Failed option: --version"

    ! acpid --help 2>&1 | grep "invalid option" && acpid --help 2>&1 | grep "Usage: acpid \[OPTIONS\]"
    CHECK_RESULT $? 0 0 "Failed option: --help"

    expect <<EOF
        spawn acpid --foreground
        expect "*starting up with netlink and the input layer*" {
            send "\003"
            expect eof {
                catch wait result
                exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: --foreground"

    expect <<EOF
        spawn acpid --foreground --logevents
        expect "*event logging is on*" {
            send "\003"
            expect eof {
                catch wait result
                exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: --logevents"

    expect <<EOF
        spawn acpid --foreground --debug
        expect "*netlink opened successfully*" {
            send "\003"
            expect eof {
                catch wait result
                exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: --debug"

    expect <<EOF
        log_file test
        spawn acpid --foreground --debug --netlink
        expect "*netlink opened successfully*" {
            send "\003"
            expect eof {
                catch wait result
                exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: --netlink"
    grep "Deprecated /proc/acpi/event was not found." test
    CHECK_RESULT $? 1 0 "Failed option: --netlink"
    rm -f ./test

    ls -al /run/ | grep "acpid.socket" | grep "root"
    CHECK_RESULT $? 0 0 "acpid.socket is not found"
    groupadd test
    acpid --socketgroup test
    SLEEP_WAIT 1
    ls -al /run/ | grep "acpid.socket" | grep "test"
    CHECK_RESULT $? 0 0 "Failed option: --socketgroup"
    acpid -g root
    SLEEP_WAIT 1
    groupdel test

    ls -al /run/ | grep "acpid.socket" | grep "srw-rw-rw-"
    CHECK_RESULT $? 0 0 "Failed option: --socketmode"
    acpid --socketmode 0777
    SLEEP_WAIT 1
    ls -al /run/ | grep "acpid.socket" | grep "srwxrwxrwx"
    CHECK_RESULT $? 0 0 "Failed option: --socketmode"
    acpid -m 0666
    SLEEP_WAIT 1

    acpid --pidfile /run/acpid.test.pid
    SLEEP_WAIT 1
    ls -al /run/ | grep "acpid.test.pid"
    CHECK_RESULT $? 0 0 "Failed option: --pidfile"
    rm -f /run/acpid.test.pid
    acpid --pidfile /run/acpid.pid
    SLEEP_WAIT 1

    LOG_INFO "End to run test."
}

# 后置处理，恢复测试环境
function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
