#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   pengrui
# @Contact   :   pengrui@uniontech.com
# @Date      :   2023-02-01
# @License   :   Mulan PSL v2
# @Desc      :   Command test-xz
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL xz    
    echo "test-xz" >>/tmp/testfile                                 
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rpm -qa | grep xz
    CHECK_RESULT $? 0 0 "Return value error" 
    xz -V
    CHECK_RESULT $? 0 0 "Version is error"
    xz -h 
    CHECK_RESULT $? 0 0 "Help value error"   
    xz -z /tmp/testfile
    test -f /tmp/testfile.xz
    CHECK_RESULT $? 0 0  "testfile.xz is right"
    xz -d /tmp/testfile.xz
    test -f /tmp/testfile
    CHECK_RESULT $? 0 0  "testfile is exist"
    xz /tmp/testfile
    test -f /tmp/testfile.xz
    CHECK_RESULT $? 0 0  "testfile.xz is success"     
    unxz /tmp/testfile.xz
    test -f /tmp/testfile
    CHECK_RESULT $? 0 0  "testfile.xz unxz success"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /tmp/testfile
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
