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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Modify    :   yang_lijin@qq.com
# @Date      :   2021/7/22
# @License   :   Mulan PSL v2
# @Desc      :   Login authentication with PAM
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function run_test() {
    LOG_INFO "Start executing testcase."
    grep "^UsePAM yes" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "grep 'UsePAM yes' failed"
    useradd testuser
    passwd testuser <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    expect <<EOF1
        log_file testlog
        set timeout 15
        spawn ssh testuser@${NODE1_IPV4} 
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password:" {
                send "test\\r"
                exp_continue
            }
        }
        expect eof
EOF1
    [ $(grep 'Permission denied' testlog | wc -l) -eq 3 ]
    CHECK_RESULT $? 0 0 "grep 'Permission denied' failed"
    SLEEP_WAIT 60
    expect <<EOF1
        log_file testlog1
        set timeout 15
        spawn ssh testuser@${NODE1_IPV4} 
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password:" {
                send "${NODE1_PASSWORD}\\r"
            }
        }
        expect eof
EOF1
    SLEEP_WAIT 10
    grep 'Last failed login' testlog1
    CHECK_RESULT $? 0 0 "grep 'Last failed login' failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    userdel -rf testuser
    rm -rf testlog testlog1 /run/faillock/testuser
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
