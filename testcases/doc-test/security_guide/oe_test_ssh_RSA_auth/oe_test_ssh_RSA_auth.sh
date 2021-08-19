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
# @Desc      :   Only allow RSA for security authentication
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function run_test() {
    LOG_INFO "Start executing testcase."
    grep "^RSAAuthentication yes" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "RSAAuthentication is not yes"
    expect <<EOF
        set timeout 15
        spawn ssh-keygen
        expect {
            "save the key" {
                send "\\r"
            }
        }
        expect {
            "Enter passphrase" {
                send "\\r"
            }
        }
        expect {
            "Enter same passphrase again" {
                send "\\r"
            }
        }
        expect eof
EOF
    ls -l /root/.ssh | grep id_rsa
    CHECK_RESULT $? 0 0 "id_rsa file is not exist"
    expect <<EOF
        set timeout 15
        spawn ssh-copy-id -i /root/.ssh/id_rsa.pub ${NODE2_USER}@${NODE2_IPV4}
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password" {
            	send "${NODE2_PASSWORD}\\r"
            }
        }
        expect eof
EOF
    SSH_CMD "grep ssh-rsa /root/.ssh/authorized_keys" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $? 0 0 "NODE2 grep ssh-rsa /root/.ssh/authorized_keys failed"
    expect <<EOF
        set timeout 15
        log_file testlog
        spawn ssh ${NODE2_USER}@${NODE2_IPV4}
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect eof
EOF
    grep "System information as of time" testlog
    CHECK_RESULT $? 0 0 "ssh log failed"
    SSH_CMD "rm -rf /root/.ssh/authorized_keys" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    expect <<EOF
        set timeout 15
        spawn ssh-keygen -t dsa
        expect {
            "save the key" {
                send "\\r"
            }
        }
        expect {
            "Enter passphrase" {
                send "\\r"
            }
        }
        expect {
            "Enter same passphrase again" {
                send "\\r"
            }
        }
        expect eof
EOF
    ls -l /root/.ssh | grep id_dsa
    CHECK_RESULT $? 0 0 "id_dsa file is not exist" 
    expect <<EOF
        set timeout 15
        spawn ssh-copy-id -i /root/.ssh/id_dsa.pub ${NODE2_USER}@${NODE2_IPV4}
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password" {
                send "${NODE2_PASSWORD}\\r"
            }
        }
        expect eof
EOF
    SSH_CMD "grep ssh-dss /root/.ssh/authorized_keys" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $? 0 0 "NODE2 grep ssh-dss /root/.ssh/authorized_keys failed"
    expect <<EOF
        set timeout 15
        log_file testlog1
        spawn ssh ${NODE2_USER}@${NODE2_IPV4}
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect eof
EOF
    grep "password:" testlog1
    CHECK_RESULT $? 0 0 "Need password"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    SSH_CMD "rm -rf /root/.ssh/authorized_keys" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rm -rf /root/.ssh/id_rsa* testlog1 testlog /root/.ssh/id_dsa*
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
