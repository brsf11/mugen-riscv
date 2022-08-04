#!/usr/bin/bash

# Copyright (c) 2022.Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   @meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2020-11-28
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test change file under /proc
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    origin=$(cat /proc/sys/fs/file-max)
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    echo 65536 >/proc/sys/fs/file-max
    grep 65536 /proc/sys/fs/file-max
    CHECK_RESULT $? 0 0 "Modify /proc/sys/fs/file-max failed."
    echo 65536 >/proc/sys/fs/file-nr
    CHECK_RESULT $? 1 0 "/proc/sys/fs/file-nr can be modified"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    echo $origin >/proc/sys/fs/file-max
    LOG_INFO "End to restore the test environment."
}

main $@

