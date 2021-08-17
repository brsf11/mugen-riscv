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
#@Desc      	:   Take the test ls command as an example
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test()
{
    LOG_INFO "Start to run test."
    
    iptables -A INPUT -p tcp -s ${NODE1_IPV4} --dport 22 -j DROP
    CHECK_RESULT $? 0 0 "add failed"
    iptables -D INPUT 1
    CHECK_RESULT $? 0 0 "delete failed"
    iptables -F
    CHECK_RESULT $? 0 0 "clean failed"
    
    LOG_INFO "End to run test."
}

main "$@"
