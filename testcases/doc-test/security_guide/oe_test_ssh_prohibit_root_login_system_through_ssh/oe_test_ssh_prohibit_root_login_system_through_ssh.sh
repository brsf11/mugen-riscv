#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wangxiaoya
# @Contact   :   wangxiaoya@qq.com
# @Date      :   2022/6/17
# @License   :   Mulan PSL v2
# @Desc      :   Prohibit the root account from directly SSH logging into the system - reinforcement is not enabled by default
# ############################################


source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    expect -c "
        set timeout 30
        log_file testlog1
        spawn ssh root@$NODE2_IPV4
        expect {
            \"*assword*\" {
                send \"$NODE2_PASSWORD\\r\"
                }
        }
        expect {
            \"*root*\" {
                send \"exit\\r\"
                }
        }     
    "
    grep "IP address" testlog1
    CHECK_RESULT $? 0 0 "Login failed."
    
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    rm -rf testlog*
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
