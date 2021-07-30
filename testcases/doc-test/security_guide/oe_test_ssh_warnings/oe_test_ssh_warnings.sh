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
# @Desc      :   Verify warnings for default network remote login
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    grep "Authorized users only. All activities may be monitored and reported." /etc/issue.net
    CHECK_RESULT $?
    expect <<EOF1
        log_file log
        set timeout 15
        spawn ssh root@127.0.0.1 
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "assword:" {
                send "${NODE1_PASSWORD}\\r"
            }
        }
        expect {
            "]" {
                send "exit\\r"
            }
        }
        expect eof
EOF1
    grep 'Authorized users only. All activities may be monitored and reported' log
    CHECK_RESULT $? 0 0 "remote login failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf log
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
