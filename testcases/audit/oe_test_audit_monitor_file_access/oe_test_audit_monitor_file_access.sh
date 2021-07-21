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
#@Date      	:   2021-04-14 16:29:43
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   monitor file access
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test()
{
    LOG_INFO "Start to run test."
    service auditd restart
    auditctl -D
    CHECK_RESULT $? 0 0 "delete rules failed"
    auditctl -w /etc/passwd -p wa -k passwd_changes
    auditctl -l | grep -e "-w /etc/passwd -p wa -k passwd_changes"
    CHECK_RESULT $? 0 0 "catch failed"
    starttime=$(date +%T)
    useradd Jevons
    CHECK_RESULT $? 0 0 "useradd failed"
    endtime=$(date +%T)
    for ((i=0;i,10;i++));do 
	    ausearch -ts "${starttime}" -te "${endtime}" -k passwd_changes
	    if [[ $? -ne 0 ]];then
		    SLEEP_WAIT 1
	    else
	   	 break
	    fi
    done
    if [[ $i -eq 10 ]];then 
	    CHECK_RESULT $? 0 0 "error"
    fi
    LOG_INFO "End to run test."
}
function post_test()
{
    LOG_INFO "Start to restore the test environment."
    userdel -rf Jevons
    auditctl -D
    LOG_INFO "End to restore the test environment."
}

main "$@"
