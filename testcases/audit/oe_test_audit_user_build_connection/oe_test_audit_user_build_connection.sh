#!/bin/bash

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
#@Desc      	:   user build connection
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    path=$(find / -name af_unix.conf)
    sed -i 's/active = no/active = yes/g' "${path}"
    service auditd restart
    DNF_INSTALL gcc
    gcc -o audit_socket audit_socket.c
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    nohup unbuffer ./audit_socket >log 2>&1 &
    sleep 1
    cat log | grep "start audit thread now!"
    CHECK_RESULT $? 0 0 "grep failed"
    touch /home/test
    auditctl -w /home/test -p a
    {
    chmod 777 /home/test
    }
    for ((i=0;i<15;i++));do
	    if [ -f 1.txt ]; then
		    break
	    fi 
	    sleep 1
    done
    if [ $i -eq 15 ];then
	    CHECK_RESULT 1 0 0 "i failed"
    fi
    if [ -f 1.txt ];then
	    grep "/home/test" 1.txt
	    if [ $? -ne 0 ];then
		    for ((j=0;j<30;j++));do
			    grep "/home/test" 1.txt
			    if [ $? -eq 0 ];then
				    break
			    fi
			    sleep 1
		    done
		    if [ $j -eq 30 ];then
			    CHECK_RESULT 1 0 0 "grep j failed"
		    fi
	    fi
    fi
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    kill ${pid}
    rm -rf log 1.txt audit_socket /home/test wait_poll
    CHECK_RESULT $? 0 0 "failed to rm"
    sed -i 's/active = yes/active = no/g' "${path}"
    service auditd restart
    auditctl -D
    LOG_INFO "End to restore the test environment."
}

main "$@"
