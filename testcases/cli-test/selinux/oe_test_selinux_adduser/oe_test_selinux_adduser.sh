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
# @Author    :   yanglijin
# @Contact   :   yang_lijin@qq.com
# @Date      :   2021/09/10
# @License   :   Mulan PSL v2
# @Desc      :   add user mapped to the selinux user
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    useradd example
    passwd example << EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    useradd -Z staff_u test
    passwd test << EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    LOG_INFO "End of environmental preparation."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    expect <<EOF
        log_file testlog
        spawn ssh example@localhost 
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
            "]*" {
                send "id -Z\\r"
            }
        }
        expect eof
EOF
    grep "unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023" testlog
    CHECK_RESULT $? 0 0 "Check unconfined_u failed"
    expect <<EOF1
        log_file testlog
        spawn ssh test@localhost
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
            "]*" {
                send "id -Z\\r"
            }
        }
        expect eof
EOF1
    grep "staff_u:staff_r:staff_t:s0" testlog
    CHECK_RESULT $? 0 0 "Check staff_r failed"
    semanage login -l | grep "test" | grep "staff_u" 
    CHECK_RESULT $? 0 0 "Check staff_u failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rf example
    userdel -rfZ test
    rm -rf testlog
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
