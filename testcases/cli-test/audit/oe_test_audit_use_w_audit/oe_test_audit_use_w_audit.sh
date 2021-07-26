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
#@Desc      	:   use -w to audit
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test()
{
    LOG_INFO "Start to run test."
    service auditd restart
    auditctl -w /home -p wa -k home_changes
    CHECK_RESULT $? 0 0 "add failed"
    auditctl -l | grep -e "-w /home -p wa -k home_changes"
    CHECK_RESULT $? 0 0 "grep failed"
    auditctl -W /home -p wa -k home_changes
    CHECK_RESULT $? 0 0 "delete failed"
    auditctl -l | grep -e "-w /home -p wa -k home_changes"
    CHECK_RESULT $? 1 0 "grep failed"
    LOG_INFO "End to run test."
}
main "$@"
