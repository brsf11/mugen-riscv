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
# @Date      :   2020/5/29
# @License   :   Mulan PSL v2
# @Desc      :   SSH checks the permissions and ownership of the user home directory before receiving the login request
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    grep "^testuser:" /etc/passwd && userdel -rf testuser
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    grep "^StrictModes yes" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "StrictModes is not yes"
    useradd testuser
    CHECK_RESULT $? 0 0 "add testuser failed"
    passwd testuser <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    chown root:root /home/testuser
    ls -l /home | grep testuser | grep "root"
    CHECK_RESULT $? 0 0 "chown /home/testuser to root failed"
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
    grep "Could not chdir to home directory /home/testuser: Permission denied" testlog
    CHECK_RESULT $? 0 0 "check the permissions and ownership of the user home directory failed"
    chmod 200 /home/testuser
    ls -l /home | grep testuser | grep 'd\-w\-\-\-\-\-\-\-'
    CHECK_RESULT $? 0 0 "check the permission of the user home directory failed"
    expect <<EOF
        set timeout 15
        log_file testlog1
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
    grep "Could not chdir to home directory /home/testuser: Permission denied" testlog1
    CHECK_RESULT $? 0 0 "check Permission failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    userdel -rf testuser
    rm -rf testlog testlog1 /run/faillock/testuser
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
