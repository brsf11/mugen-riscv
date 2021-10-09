#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   wss1235
#@Contact   	:   2115994138@qq.com
#@Date      	:   2021-06-23 11:13:00
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   command test umoci
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "umoci"
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    umoci init --layout new_image 
    ls new_image 
    CHECK_RESULT $? 0 0 "Check umoci init failed"
    umoci new --image new_image:latest
    CHECK_RESULT $? 0 0 "Check umoci new failed"
    umoci list --layout new_image | grep "latest"
    CHECK_RESULT $? 0 0 "Check umoci list failed"
    umoci config --author="test <test@xxx.com>" --image new_image
    CHECK_RESULT $? 0 0 "Check umoci config failed"
    umoci rm --image new_image:latest
    CHECK_RESULT $? 0 0 "Check umoci rm failed"
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    rm -rf new_image
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
