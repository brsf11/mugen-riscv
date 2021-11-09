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
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date          :   2021-08-16 14:00:43
#@License   	:   Mulan PSL v2
#@Desc          :   verification djvulibre's commnd
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "djvulibre ImageMagick"
    cp ../common/test* ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cjb2 --help >result 2>&1
    grep "Usage: cjb2" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check cjb2 --help failed."
    convert test3.jpg test.pbm
    cjb2 -lossy test.pbm cjb2_1.djvu
    CHECK_RESULT $? 0 0 "Check cjb2 -lossy failed."
    test -f cjb2_1.djvu
    CHECK_RESULT $? 0 0 "Check cjb2_1.djvu not exist."
    cjb2 -clean test.pbm cjb2_2.djvu
    CHECK_RESULT $? 0 0 "Check cjb2 -clean failed."
    test -f cjb2_2.djvu
    CHECK_RESULT $? 0 0 "Check cjb2_2.djvu not exist."
    cjb2 -verbose test.pbm cjb2_3.djvu
    CHECK_RESULT $? 0 0 "Check cjb2 -verbose failed."
    test -f cjb2_3.djvu
    CHECK_RESULT $? 0 0 "Check cjb2_3.djvu not exist."
    cpaldjvu --help >result 2>&1
    grep "Usage: cpaldjvu" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check cpaldjvu --help failed."
    convert test1.jpg test.ppm
    cpaldjvu -colors 256 test.ppm cpal_1.djvu
    CHECK_RESULT $? 0 0 "Check cpaldjvu -colors failed."
    test -f cpal_1.djvu
    CHECK_RESULT $? 0 0 "Check cpal_1 not exist."
    cpaldjvu -dpi 100 test.ppm cpal_2.djvu
    CHECK_RESULT $? 0 0 "Check cpaldjvu -dpi failed."
    test -f cpal_2.djvu
    CHECK_RESULT $? 0 0 "Check cpal_2 not exist."
    cpaldjvu -verbose test.ppm cpal_3.djvu
    CHECK_RESULT $? 0 0 "Check cpaldjvu -verbose failed."
    test -f cpal_3.djvu
    CHECK_RESULT $? 0 0 "Check cpal_3 not exist."
    cpaldjvu -bgwhite test.ppm cpal_4.djvu
    CHECK_RESULT $? 0 0 "Check cpaldjvu -bgwhite failed."
    test -f cpal_4.djvu
    CHECK_RESULT $? 0 0 "Check cpal_4 not exist."
    csepdjvu --help >result 2>&1
    grep "Usage: csepdjvu" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check csepdjvu --help failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -v '\.sh')
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
