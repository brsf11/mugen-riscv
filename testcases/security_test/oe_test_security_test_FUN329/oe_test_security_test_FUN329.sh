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
#@Date      	:   2021-05-19 09:39:43
#@License   	:   Mulan PSL v2
#@Desc      	:   kernel firewall
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test()
{
    LOG_INFO "Start to run test."
    
    systemctl start iptables
    CHECK_RESULT $? 0 0 "start failed"
    systemctl start iptables | grep active
    CHECK_RESULR $? 0 0 "not active"
    systemctl stop iptables
    CHECK_RESULR $? 0 0 "stop failed"
    systemctl start iptables | grep inactive
    CHECK_RESULR $? 0 0 "still active"
    systemctl restart iptables | grep active
    CHECK_RESULR $? 0 0 "restart failed"
    
    LOG_INFO "End to run test."
}

main "$@"
