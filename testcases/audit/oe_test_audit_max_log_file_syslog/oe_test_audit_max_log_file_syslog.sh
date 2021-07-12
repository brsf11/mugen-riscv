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
#@Date      	:   2021-05-31 09:39:43
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   set max log file syslog
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
source ../common/comlib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    ls /var/log/audit/audit.log && rm -rf /var/log/audit/audit.log 
    return 0
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    sed -i 's/max_log_file = 8/max_log_file = 1/g' "/etc/audit/auditd.conf"
    sed -i 's/max_log_file_action = ROTATE/max_log_file_action = SYSLOG/g' "/etc/audit/auditd.conf"
    service auditd restart
    CHECK_RESULT $?
    logSize=$(du -s /var/log/audit/audit.log | awk '{print $1}')
    if [ "${logSize}" -gt 1024 ];then
	    for (( j = 0;j < 50; j++));do
		    search_log SCEN_003
		    sleep 1
	    done
	    CHECK_RESULT $? 0 0 "search failed"
	    grep -iE "Audit daemon is low on disk space for logging" /var/log/messages
	    CHECK_RESULT $? 0 0 "grep first failed"
    else
	    create_logfile
	    grep -iE "Audit daemon is low on disk space for logging" /var/log/messages
	    CHECK_RESULT $? 0 0 "grep second failed"
	    search_log SCEN_003
	    CHECK_RESULT $? 0 0 "search second failed"
    fi
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    sed -i 's/max_log_file = 1/max_log_file = 8/g' "/etc/audit/auditd.conf"
    sed -i 's/max_log_file_action = SYSLOG/max_log_file_action = ROTATE/g' "/etc/audit/auditd.conf"
    service auditd restart
    LOG_INFO "End to restore the test environment."
}

main "$@"
