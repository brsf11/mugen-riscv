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
#@Desc      	:   monitor network visit
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    SSH_CMD "useradd Jevons" "$NODE1_IPV4" "$NODE1_PASSWORD" "$NODE1_USER"
    SSH_CMD "echo HUAWEI666 | passwd Jevons --stdin" "$NODE1_IPV4" "$NODE1_PASSWORD" "$NODE1_USER" 
    LOG_INFO "End to prepare the test environment."
}
function run_test()
{
    LOG_INFO "Start to run test."
    SSH_CMD "systemctl start auditd" "$NODE1_IPV4" "$NODE1_PASSWORD" "$NODE1_USER"
    SSH_CMD "auditctl -D" "$NODE1_IPV4" "$NODE1_PASSWORD" "$NODE1_USER"
    starttime=$(SSH_CMD "date +%T" "$NODE1_IPV4" "$NODE1_PASSWORD" "$NODE1_USER")
    expect <<EOF
    spawn ssh Jevons@${NODE1_IPV4}
    expect{
    	"*yes/no*" { send "yes\\r"; exp_continue }
    	"password:" { send "${NODE1_PASSWORD}\\r" }
    }
    expect "*#"
    send "exit \\r"
    expect eof
EOF
    sleep 10
    endtime=$(SSH_CMD "date +%T" "$NODE1_IPV4" "$NODE1_PASSWORD" "$NODE1_USER")
    sleep 1
    SSH_CMD "ausearch -ts ${starttime} -te ${endtime} -ul 1000 -m USER_LOGIN -x ssh -sv yes> /tmp/log.log 2>&1 & " "$NODE1_IPV4" "$NODE1_PASSWORD" "$NODE1_USER"
    sleep 5
    SSH_SCP "$NODE1_USER"@"$NODE1_IPV4":/tmp/log.log /tmp/ "$NODE1_PAWWORD"
    cat < /tmp/log.log |grep "<no matches>"
    CHECK_RESULT $? 1 0
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    SSH_CMD "userdel Jevons" "$NODE1_IPV4" "$NODE1_PASSWORD" "$NODE1_USER"
    SSH_CMD "rm -rf /tmp/log.log" "$NODE1_IPV4" "$NODE1_PASSWORD" "$NODE1_USER"
    rm -rf /tmp/log.log
    LOG_INFO "End to restore the test environment."
}

main "$@"
