#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.All rights reserved.
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
#@Desc      	:   Take the test access of /etc
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ls -l /etc | grep kernel | grep -q drwxr-xr-x
    CHECK_RESULT $? 0 0 "The kernel on /etc has some errors."
    ls -l /etc | grep openEuler-latest | grep -q "\-r--r--r--"
    CHECK_RESULT $? 0 0 "The openEuler-latest on /etc has some errors."
    ls -l /etc | grep openEuler_security | grep -q drwx------
    CHECK_RESULT $? 0 0 "The openEuler_security on /etc has some errors."
    ls -l /etc | grep sudoers | grep -q "\-r--r-----"
    CHECK_RESULT $? 0 0 "The sudoers on /etc has some errors."
    ls -l /etc | grep systemd | grep -q drwxr-xr-x
    CHECK_RESULT $? 0 0 "The systemd on /etc has some errors."
    dir1=('bashrc' 'environment' 'filesystems' 'networks' 'openEuler-release')
    for i in $(seq 0 $((${#dir1[@]} - 1))); do
        ls -l /etc | grep ${dir1[$i]} | grep -q "\-rw-r--r--"
        CHECK_RESULT $? 0 0 "The access of /${dir1[$i]} is false."
    done
    LOG_INFO "End to run test."
}

main "$@"

