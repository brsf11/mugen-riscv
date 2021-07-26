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
# @Date      :   2020/5/28
# @License   :   Mulan PSL v2
# @Desc      :   Password does not echo in clear text when SSH executes command remotely
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    grep "^testuser:" /etc/passwd && userdel -rf testuser
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    useradd testuser
    grep "^testuser" /etc/passwd
    CHECK_RESULT $?
    passwd testuser <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    expect <<EOF
    set timeout 15    
    log_file testlog
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
EOF
    SLEEP_WAIT 10
    grep "${NODE1_PASSWORD}" testlog
    CHECK_RESULT $? 0 1
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    userdel -rf testuser
    rm -rf testlog /run/faillock/testuser
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
