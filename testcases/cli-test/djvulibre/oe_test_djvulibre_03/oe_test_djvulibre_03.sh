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
    DNF_INSTALL djvulibre
    cp ../common/test.pdf ./
    expect <<-END
    spawn any2djvu test.pdf
    expect "]:"
    send "yes\n"
    expect eof
END
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    test -f test.djvu
    CHECK_RESULT $?
    ddjvu --help >result 2>&1
    grep "Usage: ddjvu" result && rm -rf result
    CHECK_RESULT $?
    ddjvu -verbose test.djvu ddjvu1
    CHECK_RESULT $?
    test -f ddjvu1
    CHECK_RESULT $?
    ddjvu -format=pgm test.djvu ddjvu1.pgm
    CHECK_RESULT $?
    test -f ddjvu1.pgm
    CHECK_RESULT $?
    ddjvu -aspect=no test.djvu ddjvu2
    CHECK_RESULT $?
    test -f ddjvu2
    CHECK_RESULT $?
    ddjvu -mode=mask test.djvu ddjvu3
    CHECK_RESULT $?
    test -f ddjvu3
    CHECK_RESULT $?
    ddjvu -mode=foreground test.djvu ddjvu4
    CHECK_RESULT $?
    test -f ddjvu4
    CHECK_RESULT $?
    ddjvu -mode=background test.djvu ddjvu5
    CHECK_RESULT $?
    test -f ddjvu5
    CHECK_RESULT $?
    ddjvu -skip test.djvu ddjvu6
    CHECK_RESULT $?
    test -f ddjvu6
    CHECK_RESULT $?
    djvm --help >result 2>&1
    grep "Usage:" result && rm -rf result
    CHECK_RESULT $?
    djvmcvt --help >result 2>&1
    grep "Usage:" result && rm -rf result
    CHECK_RESULT $?
    djvmcvt -b test.djvu djvmcvt.djvu
    CHECK_RESULT $?
    test -f djvmcvt.djvu
    CHECK_RESULT $?
    djvmcvt -i test.djvu ../oe_test_djvulibre_03/ djvmcvt1.djvu
    CHECK_RESULT $?
    test -f ./djvmcvt1.djvu
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -v '\.sh')
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
