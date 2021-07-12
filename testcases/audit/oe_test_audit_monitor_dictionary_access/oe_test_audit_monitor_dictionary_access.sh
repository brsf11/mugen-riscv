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
#@Date      	:   2021-04-15 11:39:43
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   monitor dictionary access
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test()
{
    LOG_INFO "Start to run test."
    systemctl start auditd
    CHECK_RESULT $? 0 0 "start failed"
    auditctl -D
    CHECK_RESULT $? 0 0 "delete failed"
    auditctl -w /opt -p wa -k opt_changes
    CHECK_RESULT $? 0 0 "add failed"
    auditctl -l | grep -e "-w /opt -p wa -k opt_changes"
    CHECK_RESULT $? 0 0 "change failed"
    starttime=$(date +%T)
    mkdir -p /opt/test/
    CHECK_RESULT $? 0 0 "create failed"
    endtime=$(date +%T)
    sleep 1
    ausearch -ts "${starttime}" -te "${endtime}" -f /opt -k opt_changes
    CHECK_RESULT $? 
    LOG_INFO "End to run test."
}
function post_test()
{
    LOG_INFO "Start to restore the test environment."
    auditctl -D
    rm -rf /opt/test
    LOG_INFO "End to restore the test environment."
}

main "$@"
