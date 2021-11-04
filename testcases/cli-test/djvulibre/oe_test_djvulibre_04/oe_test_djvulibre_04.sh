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
    LOG_INFO "Start to run test."
    test -f test.djvu
    CHECK_RESULT $?
    djvudump >result 2>&1
    grep "Usage: djvudump" result && rm -rf result
    CHECK_RESULT $?
    djvuextract --help >result 2>&1
    grep "Usage:" result && rm -rf result
    CHECK_RESULT $?
    djvumake --help >result 2>&1
    grep "Usage: djvumake" result && rm -rf result
    CHECK_RESULT $?
    djvups --help >result 2>&1
    grep "Usage: djvups" result && rm -rf result
    CHECK_RESULT $?
    djvups -color=yes test.djvu djvups1.ps
    CHECK_RESULT $?
    test -f djvups1.ps
    CHECK_RESULT $?
    djvups -color=no test.djvu djvups2.ps
    CHECK_RESULT $?
    test -f djvups2.ps
    CHECK_RESULT $?
    djvups -verbose test.djvu djvups.ps
    CHECK_RESULT $?
    test -f djvups.ps
    CHECK_RESULT $?
    djvups -format=ps test.djvu djvups3
    CHECK_RESULT $?
    test -f djvups3
    CHECK_RESULT $?
    djvups -level=2 test.djvu djvups4
    CHECK_RESULT $?
    test -f djvups4
    CHECK_RESULT $?
    djvups -orient=portrait test.djvu djvups4.djvu
    CHECK_RESULT $?
    test -f djvups4.djvu
    CHECK_RESULT $?
    djvups -mode=color test.djvu djvups5.djvu
    CHECK_RESULT $?
    test -f djvups5.djvu
    CHECK_RESULT $?
    djvups -zoom=25 test.djvu djvups6.djvu
    CHECK_RESULT $?
    test -f djvups6.djvu
    CHECK_RESULT $?
    djvups -bookletfold=18+200 test.djvu djvups7.djvu
    CHECK_RESULT $?
    test -f djvups7.djvu
    CHECK_RESULT $?
    djvups -booklet=no test.djvu djvups3.djvu
    CHECK_RESULT $?
    test -f djvups3.djvu
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
