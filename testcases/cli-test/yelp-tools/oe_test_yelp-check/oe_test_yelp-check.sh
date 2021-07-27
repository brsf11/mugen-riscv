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
#@Author    	:   Jevons
#@Contact   	:   1557927445@qq.com
#@Date      	:   2021-06-21 20:31:43
#@License   	:   Mulan PSL v2
#@Desc      	:   yelp check
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "yelp-tools yelp"
    wget https://gitlab.gnome.org/GNOME/yelp-tools/-/blob/master/help/C/yelp-check.page
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    yelp-build cache yelp-check.page
    CHECK_RESULT $? 0 0 "build failed"
    yelp-check comments index.cache
    CHECK_RESULT $? 0 0 "check failed"
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    rm -rf yelp-check.page index.cache 
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
