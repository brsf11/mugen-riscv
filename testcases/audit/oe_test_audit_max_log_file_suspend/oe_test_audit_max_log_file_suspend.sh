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
#@Desc      	:   set max log file suspend
#####################################

source ../common/comlib.sh

function pre_test(){
    LOG_INFO "Start to prepare the test environment."
    sed -i 's/max_log_file = 8/max_log_file = 1/g' "/etc/audit/auditd.conf"
    sed -i 's/max_log_file_action = ROTATE/max_log_file_action = SUSPEND/g' "/etc/audit/auditd.conf"
    service auditd restart
    LOG_INFO "End to prepare the environment"
}
function run_test()
{
    LOG_INFO "Start to run test."
    logsize=$(du -s /var/log/audit/audit.log | awk '{print $1}')
    if [ "${logsize}" -gt 1024 ];then
            service auditd status | grep "active"
            CHECK_RESULT $? 0 0 "grep first failed"
            search_log test
	        CHECK_RESULT $? 1 0 "grep first failed"
    else
            create_logfile
	        service auditd status | grep -e "active"
	        CHECK_RESULT $? 0 0 "grep second failed"
            search_log test
            CHECK_RESULT $? 1 0 "search second failed"
    fi
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    sed -i 's/max_log_file = 1/max_log_file = 8/g' "/etc/audit/auditd.conf"
    sed -i 's/max_log_file_action = SUSPEND/max_log_file_action = ROTATE/g' "/etc/audit/auditd.conf"
    service auditd restart
    LOG_INFO "End to restore the test environment."
}

main "$@"
