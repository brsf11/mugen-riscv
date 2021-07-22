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
# @Desc      :   Cipher configuration in sshd_config
# #############################################
source "${OET_PATH}/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    sed -i "s/Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,\
chacha20-poly1305@openssh.com/Ciphers aes128-ctr/g" /etc/ssh/sshd_config
    systemctl restart sshd
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
        log_file /tmp/log_128
        spawn ssh -oCiphers=aes128-ctr localhost
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password" {
                send "${NODE1_PASSWORD}\\r"
            }
        }
        expect eof
EOF
    CHECK_RESULT $?
    grep "${NODE1_IPV4}" /tmp/log_128
    CHECK_RESULT $?
    expect <<EOF
        log_file /tmp/log_256
        spawn ssh -oCiphers=aes256-ctr localhost
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password" {
                send "${NODE1_PASSWORD}\\r"
            }
        }
        expect eof
EOF
    CHECK_RESULT $? 1 0
    grep "${NODE1_IPV4}" /tmp/log_256
    CHECK_RESULT $? 1 0
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    sed -i "s/Ciphers aes128-ctr/Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,\
aes256-gcm@openssh.com,chacha20-poly1305@openssh.com/g" /etc/ssh/sshd_config
    systemctl restart sshd
    rm -rf /tmp/log_256 /tmp/log_128 /root/.ssh/known_hosts
    LOG_INFO "End to restore the test environment."
}

main "$@"
