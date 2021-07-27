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
#@Desc      	:   yelp new
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "yelp-tools yelp"
    wget https://gitlab.gnome.org/GNOME/yelp-tools/-/blob/master/help/C/yelp-new.page
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    yelp-new --stub task yelp-new.page 
    CHECK_RESULT $? 0 0 "stub failed"
    test -f "yelp-new.page.stub"
    CHECK_RESULT $? 0 0 "find first failed"
    yelp-new --tmpl task yelp-new.page
    CHECK_RESULT $? 0 0 "tmpl failed"
    test -f "yelp-new.page.tmpl"
    CHECK_RESULT $? 0 0 "find second failed"
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    rm -rf yelp-new.page.stub yelp-new.page.tmpl yelp-new.page 
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
