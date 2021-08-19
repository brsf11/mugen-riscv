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
# @Date      :   2020/05/27
# @License   :   Mulan PSL v2
# @Desc      :   User must be authenticated successfully within 60s
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    ls testlog && rm -rf testlog
    SSH_CMD "cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
            sed -i 's/#LoginGraceTime 2m/LoginGraceTime 1m/g' /etc/ssh/sshd_config
            systemctl restart sshd" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    rm -rf /root/.ssh/known_hosts
    expect <<EOF1
        log_file testlog
        spawn ssh ${NODE2_USER}@${NODE2_IPV4} 
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "assword:" {
                sleep 30
                send "${NODE2_PASSWORD}\\r"
            }
        }
        expect {
            "]#" {
                send "exit\\r"
            }
        }
        expect eof
EOF1
    grep 'Welcome to' testlog
    CHECK_RESULT $?
    rm -rf /root/.ssh/known_hosts
    rm -rf testlog
    expect <<EOF1
        log_file testlog
        spawn ssh ${NODE2_USER}@${NODE2_IPV4} 
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "assword:" {
                sleep 65
                send "${NODE2_PASSWORD}\\r"
            }
        }
        expect {
            "]#" {
                send "exit\\r"
            }
        }
        expect eof
EOF1
    grep 'Connection closed by' testlog
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    SSH_CMD "mv /etc/ssh/sshd_config.bak /etc/ssh/sshd_config -f
            systemctl restart sshd" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rm -rf testlog
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
