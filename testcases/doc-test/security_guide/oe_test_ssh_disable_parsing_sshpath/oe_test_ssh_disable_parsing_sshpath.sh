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
# @CaseName  :   test_ssh_FUN_011
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2020/6/3
# @License   :   Mulan PSL v2
# @Desc      :   Disable parsing ~/.ssh/environment and ~/.ssh/authorized during SSH login_ Environment variables set in keys
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    SSH_CMD "rm -rf /root/.ssh/environment" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    grep "^PermitUserEnvironment no" /etc/ssh/sshd_config
    CHECK_RESULT $?
    SSH_CMD "touch /root/.ssh/environment" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "chmod 600 /root/.ssh/environment" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "echo TESTENV=testenv >>/root/.ssh/environment" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
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
    CHECK_RESULT $?
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
    expect <<EOF
        set timeout 15
        spawn ssh ${NODE2_USER}@${NODE2_IPV4}
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password:" {
                send "${NODE2_PASSWORD}\\r"
            }
        } 
        expect {
            "]#" {
                send "sed -i 's/^/environment=\"TESTENV1=testenv1\" &/g' /root/.ssh/authorized_keys\\r"
            }
        }
        expect eof
EOF
    SSH_CMD "cat /root/.ssh/authorized_keys | grep 'environment=\"TESTENV1=testenv1\"'" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/root/.ssh/authorized_keys /home ${NODE2_PASSWORD}
    grep "environment=\"TESTENV1=testenv1\"" /home/authorized_keys
    CHECK_RESULT $?
    SSH_CMD "echo $TESTENV | grep testenv" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $? 0 1
    SSH_CMD "echo $TESTENV1 | grep testenv1" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $? 0 1
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    SSH_CMD "rm -rf /root/.ssh/environment /root/.ssh/authorized_keys" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rm -rf /root/.ssh/id_rsa /root/.ssh/id_rsa.pub
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
