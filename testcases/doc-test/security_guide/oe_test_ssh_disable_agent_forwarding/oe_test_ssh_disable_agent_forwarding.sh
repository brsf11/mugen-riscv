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
# @Date      :   2020/6/4
# @License   :   Mulan PSL v2
# @Desc      :   Disable SSH agent forwarding
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    cp /etc/ssh/ssh_config /etc/ssh/ssh_config-bak
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    grep "^AllowAgentForwarding no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "AllowAgentForwarding is not no"
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
        spawn ssh-copy-id -i /root/.ssh/id_rsa.pub ${NODE3_USER}@${NODE3_IPV4}
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password" {
                send "${NODE3_PASSWORD}\\r"
            }
        }
        expect eof
EOF
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/root/.ssh/authorized_keys /home ${NODE2_PASSWORD}
    grep ssh-rsa /home/authorized_keys
    CHECK_RESULT $? 0 0 "NODE2 grep ssh-rsa failed"
    rm -rf /home/authorized_keys
    SSH_SCP ${NODE3_USER}@${NODE3_IPV4}:/root/.ssh/authorized_keys /home ${NODE3_PASSWORD}
    grep ssh-rsa /home/authorized_keys
    CHECK_RESULT $? 0 0 "NODE3 grep ssh-rsa failed"
    eval $(ssh-agent)
    ssh-add /root/.ssh/id_rsa
    sed -i 's/#   ForwardAgent no/ForwardAgent yes/g' /etc/ssh/ssh_config
    systemctl restart sshd
    grep "^ForwardAgent yes" /etc/ssh/ssh_config
    CHECK_RESULT $? 0 0 "ForwardAgent is not yes"
    SSH_CMD "touch /home/test.txt" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    expect <<EOF
        set timeout 15
        log_file testlog
        spawn scp -R ${NODE2_USER}@${NODE2_IPV4}:/home/test.txt ${NODE3_USER}@${NODE3_IPV4}:/home
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect eof
EOF
    grep "password:" testlog
    CHECK_RESULT $? 0 0 "check scp failed"
    SSH_CMD "cp /etc/ssh/sshd_config /etc/ssh/sshd_config-bak
    sed -i 's/AllowAgentForwarding no/AllowAgentForwarding yes/g' /etc/ssh/sshd_config
    systemctl restart sshd" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    scp ${NODE2_USER}@${NODE2_IPV4}:/home/test.txt ${NODE3_USER}@${NODE3_IPV4}:/home
    CHECK_RESULT $? 0 0 "scp failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    mv /etc/ssh/ssh_config-bak /etc/ssh/ssh_config -f
    systemctl restart sshd
    kill -9 "$(pgrep -f ssh-agent)"
    SSH_CMD "rm -rf /root/.ssh/authorized_keys" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "rm -rf /home/test.txt" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "rm -rf /root/.ssh/authorized_keys
    mv /etc/ssh/sshd_config-bak /etc/ssh/sshd_config -f
    systemctl restart sshd" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rm -rf /root/.ssh/id_rsa /root/.ssh/id_rsa.pub testlog /home/authorized_keys
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
