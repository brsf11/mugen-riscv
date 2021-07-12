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
#@Desc      	:   rule contact strategy
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test()
{
    LOG_INFO "Start to run test."
    systemctl start auditd
    CHECK_RESULT $? 0 0 "start failed"
    service auditd status | grep running
    CHECK_RESULT $? 0 0 "grep failed"
    auditctl -D
    CHECK_RESULT $? 0 0 "delete failed"
    auditctl -w /etc/passwd -p ra -k tail
    auditctl -l | grep -e "-w /etc/passwd -p ra -k tail"
    auditctl -A always,exit -F path=/etc/passwd -F perm=ra -k head
    CHECK_RESULT $? 0 0 "add rules failed"
    auditctl -l | grep -e "-w /etc/passwd -p ra -k head"
    CHECK_RESULT $? 0 0 "grep failed"
    for ((i=0;i<10;i++)); do
	    starttime=$(date +%T)
	    cat /etc/passwd
	    CHECK_RESULT $?
	    endtime=$(date +%T)
	    ausearch -k head -ts "${starttime}" -te "${endtime}" -x cat
	    head_ret=$?
	    ausearch -k tail -ts "${starttime}" -te "${endtime}" -x cat
	    tail_ret=$?
            if [ $head_ret -eq 0 ] && [ $tail_ret -ne 0 ]; then 
		    break
	    else
		    sleep 1
 	    fi
    done
    if [ $i -eq 10 ]; then
	   CHECK_RESULT 1 0 0
    fi 
    LOG_INFO "End to run test."
}
function post_test()
{
    LOG_INFO "Start to restore the test environment."
    auditctl -D

    LOG_INFO "End to restore the test environment."
}

main "$@"
