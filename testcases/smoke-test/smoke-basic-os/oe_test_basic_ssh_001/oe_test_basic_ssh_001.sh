#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   test ssh
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    grep "testuser1:" /etc/passwd && userdel -rf testuser1
    useradd testuser1
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    usermod -aG wheel testuser1
    passwd testuser1 <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    password="${NODE1_PASSWORD}"
    expect <<EOF1
        set timeout 15
        log_file /tmp/log
        spawn ssh testuser1@127.0.0.1 pwd
        expect {
                "*(yes/no*" {
                send "yes\r"
                }
        }
        expect {
                "assword:" {
                send "${password}\r"
                }
        }
        expect eof
EOF1
    grep "/home/testuser1" /tmp/log
    CHECK_RESULT $?

    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rf testuser1
    rm -rf /tmp/log
    LOG_INFO "Finish environment cleanup!"
}

main $@
