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
#@Date      	:   2022-03-03 09:39:43
#@License   	:   Mulan PSL v2
#@Desc      	:   Test Command rootsh
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "rootsh"
    useradd testUser
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    ! rootsh --help 2>&1 | grep "invalid option" && rootsh --help 2>&1 | grep "Usage: rootsh"
    CHECK_RESULT $? 0 0 "Failed option: --help"

    ! rootsh --version 2>&1 | grep "invalid option" && rootsh --version 2>&1 | grep "rootsh version"
    CHECK_RESULT $? 0 0 "Failed option: --version"

    expect <<EOF
        log_file /var/log/test.log
        spawn rootsh --initial
        expect "Welcome*" {
            exec sleep 1
            send "exit\r"
            expect eof {
			    catch wait result
			    exit [lindex \$result 3]
		    }
        }  
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: --initial"
    cat /var/log/test.log | grep -E "Welcome"
    CHECK_RESULT $? 0 0 "Failed option: --initial"
    rm -f /var/log/test.log

    expect <<EOF
        log_file /var/log/test.log
        spawn rootsh --user=testUser
        expect "Welcome*" {
            exec sleep 1
            send "exit\r"
            expect eof {
                catch wait result
			    exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: --user"
    cat /var/log/test.log | grep -E "Welcome"
    CHECK_RESULT $? 0 0 "Failed option: --user"
    rm -f /var/log/test.log

    expect <<EOF
        spawn rootsh --user zhangsan
        expect "*does not exist" {
            expect eof {
                catch wait result
			    exit [lindex \$result 3]
            }
        }
EOF
    CHECK_RESULT $? 1 0 "Failed option: --user"

    expect <<EOF
        log_file /var/log/test.log
        spawn rootsh --logfile=log_test
        expect "Welcome*" {
            exec sleep 1
            send "exit\r"
            expect eof {
                catch wait result
			    exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: --logfile"
    cat /var/log/test.log | grep -E "Welcome"
    CHECK_RESULT $? 0 0 "Failed option: --logfile"
    rm -f /var/log/test.log

    dir=/root/my_log
    if [ ! -d "$dir" ]; then
        mkdir $dir
    fi
    expect <<EOF
        log_file /var/log/test.log
        spawn rootsh --logdir=$dir 
        expect "Welcome*" {
            exec sleep 1
            send "exit\r"
            expect eof {
                catch wait result
			    exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: --logdir"
    cat /var/log/test.log | grep -E "Welcome"
    CHECK_RESULT $? 0 0 "Failed option: --logdir"
    rm -f /var/log/test.log

    expect <<EOF
        spawn rootsh --logdir=/root/others_log
        expect "*No such file or directory" {
            expect eof {
                catch wait result
			    exit [lindex \$result 3]
            }
        }
EOF
    CHECK_RESULT $? 1 0 "Failed option: --logdir"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    userdel testUser
    LOG_INFO "End to restore the test environment."
}

main "$@"
