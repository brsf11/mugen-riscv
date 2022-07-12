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
    any2djvu --help | grep "Usage:"
    CHECK_RESULT $? 0 0 "Check any2djvu --help failed."
    expect <<-END
    spawn any2djvu http://barak.pearlmutter.net/papers mesh-preprint.ps.gz
    expect "]:"
    send "yes\n"
    sleep 10
    expect eof
END
    CHECK_RESULT $? 0 0 "Check any2djvu failed."
    test -f mesh-preprint.djvu
    CHECK_RESULT $? 0 0 "Check mesh-preprint.djvu not exist."
    expect <<-END
    spawn any2djvu test.pdf
    expect "]:"
    send "yes\n"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check any2djvu test.pdf failed."
    test -f test.djvu
    CHECK_RESULT $? 0 0 "Check test.djvu not exist."
    bzz --help >result 2>&1
    grep -E "DjVuLibre|Usage" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check bzz --help failed."
    bzz -e test.djvu bzz
    CHECK_RESULT $? 0 0 "Check bzz -e failed."
    bzz -d test.djvu bzz.djvu
    bzz -d bzz.djvu bzz1
    CHECK_RESULT $? 0 0 "Check bzz -d failed."
    c44 --help >result 2>&1
    grep -E "DjVuLibre|Usage: c44" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check c44 --help failed."
    c44 -crcbdelay 10 test1.jpg
    CHECK_RESULT $? 0 0 "Check c44 -crcbdelay failed."
    test -f test1.djvu
    CHECK_RESULT $? 0 0 "Check test1.djvu not exist."
    c44 -crcbfull test2.jpg
    CHECK_RESULT $? 0 0 "Check c44 -crcbfull failed."
    test -f test2.djvu
    CHECK_RESULT $? 0 0 "Check test2.djvu not exist."
    convert test3.jpg test.pbm
    c44 -crcbhalf test.pbm test4.djvu
    CHECK_RESULT $? 0 0 "Check c44 -crcbhalf failed."
    test -f test4.djvu
    CHECK_RESULT $? 0 0 "Check test4.djvu not exist."
    c44 -crcbnone test3.jpg test5.djvu
    CHECK_RESULT $? 0 0 "Check c44 -crcbnone failed."
    test -f test5.djvu
    CHECK_RESULT $? 0 0 "Check test5.djvu not exist."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -v '\.sh')
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
