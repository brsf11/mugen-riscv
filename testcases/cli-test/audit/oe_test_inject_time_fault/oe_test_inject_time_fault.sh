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
#@Date      	:   2021-08-04 09:39:43
#@License   	:   Mulan PSL v2
#@Desc      	:   inject time fault
#####################################

source ../common/comlib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    sed -i 's/max_log_file = 8/max_log_file = 1/g' "${AUDIT_PATH}"
    service auditd restart
    date_add=$(date -d "+1 year" +'%m/%d/%Y %H:%M:%S')
    clock --set --date="${date_add}"
    clock --hctosys

    LOG_INFO "End to prepare the test environment."
}

function log_dump() {
    old_size=$(du -ks /var/log/audit/ | awk '{print $1}')
    old_num=$(find /var/log/audit -name "audit.log*" | wc -l)
    for ((i = 0; i < 10; i++)); do
        create_logfile
        new_size=$(du -ks /var/log/audit/ | awk '{print $1}')
        test $(("$new_size" - "$old_size")) -gt 1024 && {
            new_num=$(find /var/log/audit -name "audit.log*" | wc -l)
            if [ $(("$new_num" - "$old_num")) -ge 1 ]; then
                break
            fi
        }
        test "$i" -eq 9 && {
            CHECK_RESULT 1 0 0 "failed"
        }
    done
}

function run_test() {
    LOG_INFO "Start to run test."
    
    search_log test
    log_dump
    date_less=$(date -d "-2 year " +'%m/%d/%Y %H:%M:%S')
    clock --set --date="${date_less}"
    clock --hctosys
    search_log test
    CHECK_RESULT $? 0 0 "search second failed"
    log_dump

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    date_add=$(date -d "+1 year" +'%m/%d/%Y %H:%M:%S')
    clock --set --date="${date_add}"
    clock --hctosys
    sed -i 's/max_log_file = 1/max_log_file = 8/g' "${AUDIT_PATH}"
    rm -rf /var/log/audit/audit.log*
    service auditd restart

    LOG_INFO "End to restore the test environment."
}

main "$@"
