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

    ! acpid -v | grep "invalid option" && acpid -v | grep "acpid-[0-9]*.*"
    CHECK_RESULT $? 0 0 "Failed option: -v"

    ! acpid -h 2>&1 | grep "invalid option" && acpid -h 2>&1 | grep "Usage: acpid \[OPTIONS\]"
    CHECK_RESULT $? 0 0 "Failed option: -h"

    expect <<EOF
        spawn acpid -f
        expect "*starting up with netlink and the input layer*" {
            send "\003"
            expect eof {
                catch wait result
                exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: -f"

    expect <<EOF
        spawn acpid -lf
        expect "*event logging is on*" {
            send "\003"
            expect eof {
                catch wait result
                exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: -l"

    expect <<EOF
        spawn acpid -df
        expect "*Deprecated /proc/acpi/event was not found.*" {
            send "\003"
            expect eof {
                catch wait result
                exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: -d"

    expect <<EOF
        log_file test
        spawn acpid -ndf
        expect "*netlink opened successfully*" {
            send "\003"
            expect eof {
                catch wait result
                exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: -n"
    grep "Deprecated /proc/acpi/event was not found." test
    CHECK_RESULT $? 1 0 "Failed option: -n"
    rm -f ./test

    ls -al /run/ | grep "acpid.socket" | grep "root"
    CHECK_RESULT $? 0 0 "acpid.socket is not found"
    groupadd test
    acpid -g test 
    SLEEP_WAIT 1
    ls -al /run/ | grep "acpid.socket" | grep "test"
    CHECK_RESULT $? 0 0 "Failed option: -g"
    acpid -g root 
    SLEEP_WAIT 1
    groupdel test

    ls -al /run/ | grep "acpid.socket" | grep "srw-rw-rw-" 
    CHECK_RESULT $? 0 0 "Failed option: -m"
    acpid -m 0777
    SLEEP_WAIT 1
    ls -al /run/ | grep "acpid.socket" | grep "srwxrwxrwx"
    CHECK_RESULT $? 0 0 "Failed option: -m"
    acpid -m 0666 
    SLEEP_WAIT 1

    acpid -p /run/acpid.test.pid
    SLEEP_WAIT 1
    ls -al /run/ | grep "acpid.test.pid" 
    CHECK_RESULT $? 0 0 "Failed option: -p"
    rm -f /run/acpid.test.pid
    acpid -p /run/acpid.pid
    SLEEP_WAIT 1


    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
