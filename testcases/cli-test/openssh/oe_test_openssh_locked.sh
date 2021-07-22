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
# @Desc      :   Lock and unlock SSH agent
# #############################################
source "${OET_PATH}/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
    spawn ssh-keygen
    expect {
        "*save the key*" {
            send "\n"
        }
    }
    expect {
        "*no passphrase*" {
            send "\n"
        }
    }
    expect {
        "*same passphrase*" {
            send "\n"
        }
    }
    expect eof
EOF
    CHECK_RESULT $?
    expect <<EOF
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
    CHECK_RESULT $?
    eval "$(ssh-agent -s)"
    CHECK_RESULT $?
    ssh-add ~/.ssh/id_rsa
    CHECK_RESULT $?
    expect <<EOF
        spawn ssh-add -x
        expect {
            "Enter lock password:" {
                send "123456\r"
            }
        }
        expect {
            "Again:" {
                send "123456\r"
            }
        }
        expect eof
EOF
    CHECK_RESULT $?
    ssh-add -d 2>&1 | grep "Could not remove identity"
    CHECK_RESULT $?
    ssh-add -D 2>&1 | grep "Failed to remove all identities"
    CHECK_RESULT $?
    expect <<EOF
        spawn ssh-add -X
        expect {
            "Enter lock password:" {
                send "123456\r"
            }
        }
        expect eof
EOF
    CHECK_RESULT $?
    ssh-add -D 2>&1 | grep "All identities removed"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ssh-agent -k
    rm -rf /root/.ssh/id*
    SSH_CMD "rm -rf /root/.ssh/authorized_keys" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "End to restore the test environment."
}

main "$@"
