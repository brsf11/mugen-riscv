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
# @Desc      :   check only root has uid 0
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test()
{
    LOG_INFO "Start to run test."
    
    getValue=$(cat /etc/passwd | awk -F: '{ if ($3 == 0) print $0 }')
    getNum=$(echo $getValue | wc -l)
    test $getNum -gt 1
    CHECK_RESULT $? 0 1 "one more uid 0 user have, check fail"

    echo $getValue | grep "root:x:0:0:root:/root:/bin/"
    CHECK_RESULT $? 0 0 "check uid 0 user fail"

    LOG_INFO "End to run test."
}

main "$@"