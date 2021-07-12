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
#@Desc      	:   the available disk space is less than the configured space
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
source ../common/comlib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    cp -raf /var/log/ /tmp/
    cat ${AUDIT_PATH}
    sed -i 's/log_file = \/var\/log\/audit\/audit.log/log_file = \/tmp\/log\/audit\/audit.log/g' "/etc/audit/auditd.conf"
    sed -i 's/max_log_file_action = ROTATE/max_log_file_action = KEEP_LOGS/g' "/etc/audit/auditd.conf"
    service auditd restart
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    count_size=$(df -m /tmp/log/audit/ | awk 'NR==2' | awk '{print $4-74}')
    dd if=/dev/zero of=/tmp/log/audit/audit_log bs=1M count="${count_size}"
    for ((j=0;j<10;j++));do
	    sleep 1
            search_log available_disk_space
	    CHECK_RESULT $? 0 0 "search first"
    done
    sleep 1
    grep -iE "Audit daemon is low on disk space for logging" /var/log/messages
    CHECK_RESULT $? 0 0 "grep logging first failed"
    count_size=$(df -m /tmp/log/audit/ | awk 'NR==2' | awk '{print $4-49}')
    dd if=/dev/zero of=/tmp/log/audit/audit_log bs=1M count="${count_size}"
    search_log available_disk_space
    sleep 10
    service auditd status 
    service auditd status | grep "active (running)"
    CHECK_RESULT $? 0 0 "grep active failed"
    sleep 10
    service auditd status | grep "Audit daemon is low on disk space for logging"
    CHECK_RESULT $? 0 0 "grep logging second failed"
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    sed -i 's/log_file = \/tmp\/log\/audit\/audit.log/log_file = \/var\/log\/audit\/audit.log/g' "${AUDIT_PATH}"
    sed -i 's/max_log_file_action = KEEP_LOGS/max_log_file_action = ROTATE/g' "${AUDIT_PATH}"
    service auditd restart
    cat ${AUDIT_PATH}
    rm -rf /tmp/log
    LOG_INFO "End to restore the test environment."
}

main "$@"
