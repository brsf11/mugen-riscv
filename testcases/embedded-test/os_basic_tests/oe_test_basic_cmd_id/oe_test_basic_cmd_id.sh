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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   View user and group id
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test(){
    LOG_INFO "Start to prepare the test environment."
    
    id_num=$(id | grep -iE 'uid|gid' | awk -F "=" '{print$2}' | awk -F '(' '{print$1}')
    
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."

    id | grep -iE 'uid|gid'
    CHECK_RESULT $? 0 0 "check id title fail"
    id -g | grep "${id_num}"
    CHECK_RESULT $? 0 0 "check group id number fail"
    id -G | grep "${id_num}"
    CHECK_RESULT $? 0 0 "check supplementary group ids fail"
    id --help 2>&1 | grep -i usage
    CHECK_RESULT $? 0 0 "check id help fail"

    LOG_INFO "End to run test."
}

main "$@"
