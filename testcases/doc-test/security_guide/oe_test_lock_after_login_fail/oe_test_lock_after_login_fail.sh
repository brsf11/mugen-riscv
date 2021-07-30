#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detailAs.

# #############################################
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2020/05/29
# @License   :   Mulan PSL v2
# @Desc      :   Lock after login failure more than three times
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    grep "^test:" /etc/passwd && userdel -rf test
    ls testlog && rm -rf testlog
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    useradd test
    passwd test <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    expect <<EOF1
        log_file testlog
        set timeout 15
        spawn ssh test@127.0.0.1
        expect {
                "*yes/no*" {
                send "yes\\r"
                }
        }
        expect {
                "assword:" {
                send "test\\r";
                exp_continue;
                }

        }
        expect eof
EOF1
    [ $(grep -c 'Permission denied' testlog) -eq 3 ]
    CHECK_RESULT $? 0 0 "grep 'Permission denied' failed"
    rm -rf testlog
    expect <<EOF1
        log_file testlog
        set timeout 15
        spawn ssh test@127.0.0.1
        expect {
                "*yes/no*" {
                send "yes\\r"
                }
        }
        expect {
                "assword:" {
                send "${NODE1_PASSWORD}\\r";
                exp_continue;
                }
        }
        expect {
                "]" {
                send "exit\\r"
                }
        }
        expect eof
EOF1
    [ $(grep -c 'Permission denied' testlog) -eq 3 ]
    CHECK_RESULT $? 0 0 "lock failed"
    SLEEP_WAIT 45
    expect <<EOF1
        log_file testlog
        set timeout 15
        spawn ssh test@127.0.0.1
        expect {
                "*yes/no*" {
                send "yes\\r"
                }
        }
        expect {
                "assword:" {
                send "${NODE1_PASSWORD}\\r"
                }
        }
        expect {
                "]" {
                send "exit\\r"
                }
        }
        expect eof
EOF1
    grep '\[test@localhost' testlog
    CHECK_RESULT $? 0 0 "login failed"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start cleanning environment"
    userdel -rf test
    rm -rf testlog /run/faillock/test
    SLEEP_WAIT 10
    LOG_INFO "Finish environment cleanupp"
}

main "$@"

