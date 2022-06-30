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
    sleep 10
    expect eof
END
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    test -f test.djvu
    CHECK_RESULT $? 0 0 "Check test.djvu not exist."
    ddjvu --help >result 2>&1
    grep "Usage: ddjvu" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check ddjvu --help failed."
    ddjvu -verbose test.djvu ddjvu1
    CHECK_RESULT $? 0 0 "Check ddjvu -verbose failed."
    test -f ddjvu1
    CHECK_RESULT $? 0 0 "Check ddjvu1 not exist."
    ddjvu -format=pgm test.djvu ddjvu1.pgm
    CHECK_RESULT $? 0 0 "Check ddjvu -format=pgm failed."
    test -f ddjvu1.pgm
    CHECK_RESULT $? 0 0 "Check ddjvu1.pgm not exist."
    ddjvu -aspect=no test.djvu ddjvu2
    CHECK_RESULT $? 0 0 "Check ddjvu -aspect=no failed."
    test -f ddjvu2
    CHECK_RESULT $? 0 0 "Check ddjvu2 not exist."
    ddjvu -mode=mask test.djvu ddjvu3
    CHECK_RESULT $? 0 0 "Check ddjvu -mode=mask failed."
    test -f ddjvu3
    CHECK_RESULT $? 0 0 "Check ddjvu3 not exist."
    ddjvu -mode=foreground test.djvu ddjvu4
    CHECK_RESULT $? 0 0 "Check ddjvu -mode=foreground failed."
    test -f ddjvu4
    CHECK_RESULT $? 0 0 "Check ddjvu4 not exist."
    ddjvu -mode=background test.djvu ddjvu5
    CHECK_RESULT $? 0 0 "Check ddjvu -mode=background failed."
    test -f ddjvu5
    CHECK_RESULT $? 0 0 "Check ddjvu5 not exist."
    ddjvu -skip test.djvu ddjvu6
    CHECK_RESULT $? 0 0 "Check ddjvu -skip failed."
    test -f ddjvu6
    CHECK_RESULT $? 0 0 "Check ddjvu6 not exist."
    djvm --help >result 2>&1
    grep "Usage:" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check djvm --help failed."
    djvmcvt --help >result 2>&1
    grep "Usage:" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check djvmcvt --help failed."
    djvmcvt -b test.djvu djvmcvt.djvu
    CHECK_RESULT $? 0 0 "Check djvmcvt -b failed."
    test -f djvmcvt.djvu
    CHECK_RESULT $? 0 0 "Check djvmcvt.djvu not exist."
    djvmcvt -i test.djvu ../oe_test_djvulibre_03/ djvmcvt1.djvu
    CHECK_RESULT $? 0 0 "Check djvmcvt -i failed."
    test -f ./djvmcvt1.djvu
    CHECK_RESULT $? 0 0 "Check djvmcvt1.djvu not exist."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -v '\.sh')
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
