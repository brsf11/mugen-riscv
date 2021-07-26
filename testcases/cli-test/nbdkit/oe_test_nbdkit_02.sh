#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/12/15
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in ndisc6-server binary package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "nbdkit nbdkit-server nbdkit-plugins gnutls-utils"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    nbdkit -n example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit -o example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    echo "531681" >example.pid
    nbdkit -P example.pid example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example.pid example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit -p 10809 example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "10809 example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit -r example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "nbdkit -r example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit --run hostname example1
    CHECK_RESULT $?
    nbdkit --selinux-label system_u:object_r:svirt_t:s0 example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "system_u:object_r:svirt_t:s0 example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit --threads 1 example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    nbdkit example1
    CHECK_RESULT $?
    kill -9 $(ps -aux | grep "example1" | awk 'NR==1{print $2}')
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf example.pid
    LOG_INFO "End to restore the test environment."
}

main "$@"
