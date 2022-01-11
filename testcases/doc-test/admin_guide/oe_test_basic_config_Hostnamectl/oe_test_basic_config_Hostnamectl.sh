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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020.04-27
# @License   :   Mulan PSL v2
# @Desc      :   hostnamectl configuration hostname test
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase!"
    hostname="hostnamectl status | awk -F' ' '{print $NF}'  | sed -n 1p"
    remotehost=`SSH_CMD "hostnamectl status | awk -F' ' '{print $NF}'  | sed -n 1p" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}`
    hostnamectl set-hostname my_host
    hostnamectl status | grep "Pretty hostname: my_host"
    CHECK_RESULT $?
    hostnamectl set-hostname "Tester's notebook" --pretty
    hostnamectl status | grep "Pretty hostname" | grep "Tester's notebook"
    CHECK_RESULT $?
    hostnamectl set-hostname "" --pretty
    hostnamectl status | grep "Pretty hostname"
    CHECK_RESULT $? 1
    expect <<-EOF
    spawn hostnamectl set-hostname -H root@${NODE2_IPV4} new_host
    expect {
        "Are you sure you want to continue connecting*"
        {
            send "yes\r"
            expect "*\[P|p]assword:"
            send "${NODE2_PASSWORD}\r"
        }
        "*\[P|p]assword:"
        {
            send "${NODE2_PASSWORD}\r"
        }
    }
    expect eof
EOF
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    hostnamectl set-hostname ${hostname}
    expect <<-EOF
    spawn hostnamectl set-hostname -H root@${NODE2_IPV4} ${remotehost}
    expect {
        "Are you sure you want to continue connecting (yes/no)?"
        {
            send "yes\r"
            expect "*\[P|p]assword:"
            send "${NODE2_PASSWORD}\r"
        }
        "*\[P|p]assword:"
        {
            send "${NODE2_PASSWORD}\r"
        }
    }
    expect eof
EOF
    LOG_INFO "Finish environment cleanup."
}

main $@
