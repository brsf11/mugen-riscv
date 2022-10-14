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
#@Date      	:   2020-11-18
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test access of /boot
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ls -l /boot | grep "config" | grep "\-rw-r--r--"
    CHECK_RESULT $? 0 0 "The config on /boot has some errors."
    ls -l /boot | grep "grub2" | grep "drwx------"
    CHECK_RESULT $? 0 0 "The grub2 on /boot has some errors."
    ls -l /boot | grep "initramfs" | grep "\-rw-------"
    CHECK_RESULT $? 0 0 "The initramfs on /boot has some errors."
    LOG_INFO "End to run test."
}

main "$@"
