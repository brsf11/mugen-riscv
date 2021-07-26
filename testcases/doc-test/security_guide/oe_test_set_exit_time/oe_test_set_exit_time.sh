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
# @Modify    :   yang_lijin@qq.com
# @Date      :   2020/05/27
# @License   :   Mulan PSL v2
# @Desc      :   The terminal stops running for 30 seconds and exits automatically
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    cp /etc/profile /etc/profile.bak
    echo \\'TMOUT=30\\' >/etc/profile
    source /etc/profile
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    echo "expect<<EOF1
        set timeout 15
        spawn ssh ${NODE1_USER}@${NODE1_IPV4} 
        expect {
            \"*yes/no*\" {
                send \"yes\\r\"
            }
        }
        expect {
            \"assword:\" {
                send \"${NODE1_PASSWORD}\\r\"
            }
        }
        expect eof
EOF1" >/tmp/ssh_remote.sh
    rm -rf /root/.ssh/known_hosts
    bash -x /tmp/ssh_remote.sh &
    SLEEP_WAIT 2
    ps -axu | grep ssh | grep ${NODE1_IPV4}
    CHECK_RESULT $? 0 0 "terminal not running"
    SLEEP_WAIT 35
    ps -axu | grep ssh | grep ${NODE1_IPV4}
    CHECK_RESULT $? 0 1 "terminal running"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    mv /etc/profile.bak /etc/profile -f
    source /etc/profile
    rm -rf /tmp/ssh_remote.sh
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
