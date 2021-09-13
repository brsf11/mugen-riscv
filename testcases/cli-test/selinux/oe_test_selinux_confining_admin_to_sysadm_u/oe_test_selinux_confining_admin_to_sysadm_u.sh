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
# @Desc      :   confining admin to sysadm_u
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    adduser -G wheel -Z sysadm_u example
    passwd example << EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    LOG_INFO "End of environmental preparation."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    setsebool -P ssh_sysadm_login on
    getsebool ssh_sysadm_login | grep "ssh_sysadm_login --> on"
    CHECK_RESULT $? 0 0 "set ssh_sysadm_login on failed"
    semanage login -l | grep "example.*sysadm_u.*s0"
    CHECK_RESULT $? 0 0 "Check example sysadm_u failed"
    expect <<EOF1
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
        expect {
             "]*" {
                send "sudo -i\\r"
             }
        }
        expect {
             "example:" {
                send "${NODE1_PASSWORD}\\r"
             }
        }
        expect {
             "]*" {
                 send "id -Z\\r"
             }
        }
        expect eof
EOF1
    grep -c "sysadm_u:sysadm_r:sysadm_t:s0" testlog | grep '2'
    CHECK_RESULT $? 0 0 "Check id -Z failed" 
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rfZ example
    rm -rf testlog
    setsebool -P ssh_sysadm_login off
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
