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
# @Desc      :   Test whether SSH protocol version is 2
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    ls testlog && rm -rf testlog
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    grep "Protocol 2" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "SSH protocol version is not 2"
    ssh -1 ${NODE1_USER}@${NODE1_IPV4} 2>&1 | grep "SSH protocol v.1 is no longer supported"
    CHECK_RESULT $? 0 0 "SSH protocol version is 1"
    expect <<EOF
        set timeout 15
        log_file testlog
        spawn ssh -2 ${NODE1_USER}@${NODE1_IPV4}
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
    grep "System information as of time" testlog
    CHECK_RESULT $? 0 0 "login failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    rm -rf testlog
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
