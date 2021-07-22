#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.
# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   SSH agent avoids entering private key password
# #############################################
source "${OET_PATH}/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    ssh-keygen -f ~/.ssh/id_rsa_agent -P '123456'
    CHECK_RESULT $?
    expect <<EOF
        spawn ssh-copy-id -i /root/.ssh/id_rsa_agent.pub ${NODE2_USER}@${NODE2_IPV4}
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
    CHECK_RESULT $?
    eval "$(ssh-agent -s)"
    CHECK_RESULT $?
    expect <<EOF
        spawn ssh-add /root/.ssh/id_rsa_agent
        expect {
            "passphrase" {
                send "123456\\r"
            }
        }
        expect eof
EOF
    CHECK_RESULT $?
    ssh-add -l | grep "SHA256"
    CHECK_RESULT $?
    ssh-add -L | grep "ssh-rsa"
    CHECK_RESULT $?
    expect <<EOF
        set timeout 15
        log_file /tmp/log
        spawn ssh ${NODE2_USER}@${NODE2_IPV4}
        expect {
            "]#" {
                send "ip a\r"
            }
        }
        expect eof
EOF
    CHECK_RESULT $?
    grep "inet ${NODE2_IPV4}" /tmp/log
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ssh-add -d ~/.ssh/id_rsa_agent
    ssh-agent -k
    SSH_CMD "rm -rf /root/.ssh/authorized_keys" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    rm -rf /root/.ssh/id_rsa* /tmp/log
    LOG_INFO "End to restore the test environment."
}

main "$@"
