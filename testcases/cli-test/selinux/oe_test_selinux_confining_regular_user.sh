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
# @Author    :   yanglijin
# @Contact   :   yang_lijin@qq.com
# @Date      :   2021/09/10
# @License   :   Mulan PSL v2
# @Desc      :   confining regular user
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    User=$(semanage login -l | grep "__default__" | awk '{print $2}')
    Range=$(semanage login -l | grep "__default__" | awk '{print $3}')
    LOG_INFO "End of environmental preparation."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    semanage login -m -s user_u -r s0 __default__
    semanage login -l | grep "__default__" | grep "user_u"
    CHECK_RESULT $? 0 0 "Check user_u failed"
    useradd example
    passwd example << EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    expect <<EOF
        log_file testlog
        spawn ssh example@localhost 
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
            "]*" {
                send "id -Z\\r"
            }
        }
        expect eof
EOF
    grep "user_u:user_r:user_t:s0" testlog
    CHECK_RESULT $? 0 0 "Check id user_u:user_r:user_t failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rfZ example
    semanage login -m -s $User -r $Range __default__
    rm -rf testlog
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
