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
# @Date      :   2020/05/28
# @License   :   Mulan PSL v2
# @Desc      :   Shield system account
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    grep "^test:" /etc/passwd && userdel -rf test
    ls log && rm -rf log
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    useradd test
    passwd test <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    expect <<EOF1
        log_file log
        spawn ssh test@127.0.0.1 pwd
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
	    expect eof
EOF1
    grep '/home/test' log
    CHECK_RESULT $?
    rm -rf log
    usermod -L -s /sbin/nologin test
    expect <<EOF1
        log_file log
        spawn ssh test@127.0.0.1 pwd
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
            "assword:" {
                send "${NODE1_PASSWORD}\\r"
	    	}
        }
        expect {
            "assword:" {
                send "${NODE1_PASSWORD}\\r"
	    	}
        }
	    expect eof
EOF1
    grep 'Permission denied' log
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rf test
    rm -rf log /run/faillock/test
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
