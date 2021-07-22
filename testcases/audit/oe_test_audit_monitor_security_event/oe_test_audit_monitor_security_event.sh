#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   Jevons
#@Contact   	:   1557927445@qq.com
#@Date      	:   2021-04-16 11:39:43
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   monitor security event
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    useradd Jevons
    echo HUAWEI666 | passwd Jevons --stdin
    LOG_INFO "End to prepare the test environment."
}
function run_test()
{
    LOG_INFO "Start to run test."
    service auditd restart
    auditctl -D
    starttime=$(date +%T)
    expect <<EOF
    spawn ssh Jevons@localhost
    expect{
    	"*yes/no*" { send "yes\\r"; exp_continue }
    	"password:" { send "HUAWEI666\\r" }
    }
    expect "*#"
    send "exit \\r"
    expect eof
EOF
    SLEEP_WAIT 10
    endtime=$(date +%T)
    ausearch -ts ${starttime} -te ${endtime} -m USER_LOGIN -sv no > /tmp/log.log 
    SLEEP_WAIT 5
    cat < /tmp/log.log | grep "<no matches>"
    CHECK_RESULT $? 1 0 "grep failed"
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    userdel Jevons
    rm -rf /tmp/log.log
    LOG_INFO "End to restore the test environment."
}

main "$@"
