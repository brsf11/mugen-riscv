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
# @Date      :   2022/6/10
# @License   :   Mulan PSL v2
# @Desc      :   Su permission restriction - enable reinforcement by default
# ############################################


source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    useradd test1
    useradd test2
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    expect -c "
        set timeout 30
        spawn passwd test1
        expect {
            \"*assword*\" {
                send \"qqq\\r\"
                }
        }
        expect {
            \"*assword*\" {
                send \"qqq\\r\"
                }
        }     
    "
    expect -c "
        set timeout 30
        spawn passwd test2
        expect {
            \"*assword*\" {
                send \"qqq\\r\"
                }
        }
        expect {
            \"*assword*\" {
                send \"qqq\\r\"
                }
        }     
    "    
    usermod -a -G wheel test1
    expect -c "
        set timeout 30
        log_file testlog1
        spawn su test2
        expect {
            \"*assword*\" {
                send \"qqq\\r\"
                }
        }
        expect {
            \"*test2@*\" {
                send \"pwd\\r\"
                }
        } 
        expect {
            \"*test2@*\" {
                send \"exit\\r\"
                }
        }             
    "    
    grep "IP address" testlog1
    CHECK_RESULT $? 0 0 "Login failed."
    expect -c "
        set timeout 30
        log_file testlog2
        spawn su test1
        expect {
            \"*assword*\" {
                send \"qqq\\r\"
                }
        }
        expect {
            \"*test1@*\" {
                send \"su test 2\\r\"
                }
        }   
        expect {
            \"*test2@*\" {
                send \"pwd\\r\"
                }
        }    
        expect {
            \"*test2@*\" {
                send \"exit\\r\"
                }
        } 
        expect {
            \"*test1@*\" {
                send \"exit\\r\"
                }
        }                          
    "  
    grep "IP address" testlog2
    CHECK_RESULT $? 0 0 "Login failed."
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    rm -rf testlog*
    userdel -rf test*
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
