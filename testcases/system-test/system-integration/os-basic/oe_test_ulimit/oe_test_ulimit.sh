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
# @Author    :   liuyafei1
# @Contact   :   liuyafei@uniontech.com
# @Date      :   2022-10-13
# @License   :   Mulan PSL v2
# @Desc      :   Command test-ulimit
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8    
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ulimit -a | awk -F: '{print $0}'|grep 'max memory size' | grep unlimited
    CHECK_RESULT $? 0 0  "check max memory size unlimited result fail"
    ulimit_value1=$(ulimit -n | awk '{print $1}')
    ulimit_value2=$(ulimit -n | awk -F: '{print $0}')
    CHECK_RESULT $((ulimit_value1)) $((ulimit_value2)) 0  "check ulimit's result fail"
    ulimit --help | grep "ulimit"
    CHECK_RESULT $? 0 0 "check ulimit's help manual fail"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    export LANG=${OLD_LANG}
    LOG_INFO "Finish environment cleanup!"
}

main "$@"



