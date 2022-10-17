#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   @meitingli
#@Contact   	:   bubble_mt@outlook.com
#@Date      	:   2020-11-19
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test access of /run
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ls -l /run | grep "initctl" | grep -q "prw-------"
    CHECK_RESULT $? 0 0 "The initctl on /run has some errors."
    ls -l /run | grep "utmp" | grep -q "\-rw-rw-r--"
    CHECK_RESULT $? 0 0 "The utmp on /run has some errors."
    dir=('fsck' 'log' 'mount' 'systemd' 'udev' 'user')
    for i in $(seq 0 $((${#dir[@]} - 1))); do
        ls -l /run | grep ${dir[$i]} | grep -q 'drwxr-xr-x'
        CHECK_RESULT $? 0 0 "The access of /${dir[$i]} is false."
    done
    LOG_INFO "End to run test."
}

main "$@"

