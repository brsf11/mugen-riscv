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
# @Desc      :   Character interface waiting timeout limit - reinforcement is not enabled by default
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
    grep "^#ClientAliveInterval" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "Security reinforcement is not enabled by default, but security reinforcement is performed here."
    expect -c "
        set timeout 30
        spawn ssh root@$NODE2_IPV4
        expect {
            \"*assword*\" {
                send \"$NODE2_PASSWORD\\r\"
                }
        }
        sleep 360
        expect {
            \"root*\" {
                send \"pwd\r\"
                }
        }
        expect {
            \"root*\" {
                send \"exit\r\"
                }
        }
        expect eof {
            catch wait result
            exit [lindex \$result 3] 
        }
    "
    CHECK_RESULT $? 0 0 "The character interface waiting timeout limit is set."
    LOG_INFO "Finish testcase execution."
}

main "$@"
