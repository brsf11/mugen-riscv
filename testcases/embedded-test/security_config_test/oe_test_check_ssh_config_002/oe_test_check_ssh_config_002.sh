#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   saarloos
# @Contact   :   9090-90-90-9090@163.com
# @Modify    :   9090-90-90-9090@163.com
# @Date      :   2022/04/25
# @License   :   Mulan PSL v2
# @Desc      :   check HostbasedAuthentication
#                check PermitRootLogin
#                check PermitEmptyPasswords
#                check PermitUserEnvironment
#                check MACs
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test()
{
    LOG_INFO "Start to run test."

    # check HostbasedAuthentication
    grep "^\s*HostbasedAuthentication no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "check SSH HostbasedAuthentication set fail"

    # check PermitRootLogin
    grep "^\s*PermitRootLogin no" /etc/ssh/sshd_config
    LOG_WARN "check SSH PermitRootLogin set result: $?, success is 0, fail is 1"

    # check PermitEmptyPasswords
    grep "^\s*PermitEmptyPasswords no" /etc/ssh/sshd_config
    LOG_WARN "check SSH PermitEmptyPasswords set result: $?, success is 0, fail is 1"

    # check PermitUserEnvironment
    grep "^\s*PermitUserEnvironment no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "check SSH PermitUserEnvironment set fail"

    # check MACs
    getValue=$(grep -i "^MACs" /etc/ssh/sshd_config)
    CHECK_RESULT $? 0 0 "check SSH MACs not set"
    
    getNum=$(echo $getValue | awk -F ',' '{\
        flag=1; \
        for(x=1; x<=NF; x++){ \
            if (index($x, "-etm")==0 && flag != 0) { \
                    flag=0 \
            } \
            if (flag == 0 && index($x, "-etm")>0) { \
                print $x \
            } \
        }\
    }' | wc -l)

    test $getNum -gt 0
    CHECK_RESULT $? 0 1 "check MACs set fail"

    LOG_INFO "End to run test."
}

main "$@"
