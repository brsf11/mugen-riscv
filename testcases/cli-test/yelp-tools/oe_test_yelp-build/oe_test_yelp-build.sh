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
#@Desc      	:   yelp build                  
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "yelp-tools yelp"
    wget https://gitlab.gnome.org/GNOME/yelp-tools/-/blob/master/help/C/yelp-build.page
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    yelp-build html yelp-build.page
    CHECK_RESULT $? 0 0 "html failed"
    test -f "highlight.pack.js" 
    CHECK_RESULT $? 0 0  "find html failed"
    yelp-build cache yelp-build.page
    CHECK_RESULT $? 0 0 "cache failed"
    test -f "index.cache"
    CHECK_RESULT $? 0 0 "find cache failed"
    yelp-build epub yelp-build.page
    CHECK_RESULT $? 0 0 "epub failed"
    test -f "index.epub"
    CHECK_RESULT $? 0 0 "find epub failed"
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    rm -rf highlight.pack.js index.cache index.epub yelp-build.page C.css yelp-build.html yelp.js
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
