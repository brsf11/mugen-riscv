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
# @modify    :   yang_lijin@qq.com
# @Date      :   2021/05/11
# @License   :   Mulan PSL v2
# @Desc      :   Allow public key authentication
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function run_test() {
    LOG_INFO "Start executing testcase."
    grep "^PubkeyAuthentication yes" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "grep 'PubkeyAuthentication yes' failed"
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
    CHECK_RESULT $? 0 0 "grep id_rsa failed"
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
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/root/.ssh/authorized_keys /home ${NODE2_PASSWORD}
    grep ssh-rsa /home/authorized_keys
    CHECK_RESULT $? 0 0 "grep ssh-rsa failed"
    expect <<EOF
        set timeout 15
        log_file testlog
        spawn ssh ${NODE2_USER}@${NODE2_IPV4}
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
    SLEEP_WAIT 1
    grep '\[root@openEuler ~]#' testlog
    CHECK_RESULT $? 0 0 "login failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    SSH_CMD "rm -rf /root/.ssh/authorized_keys" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rm -rf /root/.ssh/id_rsa /root/.ssh/id_rsa.pub /home/authorized_keys testlog
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
