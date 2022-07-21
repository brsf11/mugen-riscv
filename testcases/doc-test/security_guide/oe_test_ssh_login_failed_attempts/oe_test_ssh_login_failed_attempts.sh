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
# @Date      :   2022/6/9
# @License   :   Mulan PSL v2
# @Desc      :   Password complexity limit - reinforcement is not enabled by default
# ############################################


source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    systemctl restart sshd.service
    SLEEP_WAIT 1
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    expect -c "
        set timeout 30
        log_file testlog1
        spawn ssh root@$NODE2_IPV4
        expect {
            \"*assword*\" {
                send \"error_pwd\\r\"
                }
        }
        expect {
            \"*assword*\" {
                send \"error_pwd\\r\"
                }
        }
        expect {
            \"*assword*\" {
                send \"error_pwd\\r\"
                }
        }        
        expect eof {
            catch wait result
            exit [lindex \$result 3] 
        }
    "
    CHECK_RESULT $? 0 1 "Login succeeded, but the login should fail here."
    grep "please try again" testlog1
    CHECK_RESULT $? 0 0 "Retry prompt not found."
    expect -c "
        set timeout 30
        log_file testlog2
        spawn ssh root@$NODE2_IPV4
        expect {
            \"*assword*\" {
                send \"$NODE2_PASSWORD\\r\"
                }
        }   
         expect {
            \"*assword*\" {
                send \"$NODE2_PASSWORD\\r\"
                }
        }  
        expect {
            \"*assword*\" {
                send \"$NODE2_PASSWORD\\r\"
                }
        }                    
        expect eof {
            catch wait result
            exit [lindex \$result 3] 
        }
    "
    CHECK_RESULT $? 0 1 "It should be locked for 1 minute after entering the wrong password for three times, but it is not locked here."
    grep "please try again" testlog2
    CHECK_RESULT $? 0 0 "Retry prompt not found."
    SLEEP_WAIT 60
    expect -c "
        set timeout 30
        log_file testlog3
        spawn ssh root@$NODE2_IPV4
        expect {
            \"*assword*\" {
                send \"$NODE2_PASSWORD\\r\"
                }
        }      
        expect eof {
            catch wait result
            exit [lindex \$result 3] 
        }
    "
    CHECK_RESULT $? 0 0 "Login failed."
    grep "IP address" testlog3
    CHECK_RESULT $? 0 0 "Login failed."

    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    rm -rf testlog*
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
