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
function config_params() {
    LOG_INFO "This test case has no config params to load!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    cat /etc/passwd | grep "testuser1:" && userdel -rf testuser1
    useradd testuser1
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    sed -i 's/#%wheel/%wheel/g' /etc/sudoers
    usermod -aG wheel testuser1
    passwd testuser1 <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    password="${NODE1_PASSWORD}"
    expect <<EOF1
        set timeout 15
        log_file log
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
    cat log | grep "/home/testuser1"
    CHECK_RESULT $?

    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rf testuser1
    rm -rf log
    LOG_INFO "Finish environment cleanup!"
}

main $@
