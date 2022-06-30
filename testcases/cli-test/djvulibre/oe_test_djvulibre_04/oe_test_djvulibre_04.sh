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
    LOG_INFO "Start to run test."
    test -f test.djvu
    CHECK_RESULT $? 0 0 "Check test.djvu not exist."
    djvudump >result 2>&1
    grep "Usage: djvudump" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check djvudump failed."
    djvuextract --help >result 2>&1
    grep "Usage:" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check djvuextract --help failed."
    djvumake --help >result 2>&1
    grep "Usage: djvumake" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check djvumake --help failed."
    djvups --help >result 2>&1
    grep "Usage: djvups" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check djvups --help failed."
    djvups -color=yes test.djvu djvups1.ps
    CHECK_RESULT $? 0 0 "Check djvups -color=yes failed."
    test -f djvups1.ps
    CHECK_RESULT $? 0 0 "Check djvups1.ps not exist."
    djvups -color=no test.djvu djvups2.ps
    CHECK_RESULT $? 0 0 "Check djvups -color=no failed."
    test -f djvups2.ps
    CHECK_RESULT $? 0 0 "Check djvups2.ps not exist."
    djvups -verbose test.djvu djvups.ps
    CHECK_RESULT $? 0 0 "Check djvups -verbose failed."
    test -f djvups.ps
    CHECK_RESULT $? 0 0 "Check djvups.ps not exist."
    djvups -format=ps test.djvu djvups3
    CHECK_RESULT $? 0 0 "Check djvups -format=ps failed."
    test -f djvups3
    CHECK_RESULT $? 0 0 "Check djvups3.ps not exist."
    djvups -level=2 test.djvu djvups4
    CHECK_RESULT $? 0 0 "Check djvups -level=2 failed."
    test -f djvups4
    CHECK_RESULT $? 0 0 "Check djvups4.ps not exist."
    djvups -orient=portrait test.djvu djvups42.djvu
    CHECK_RESULT $? 0 0 "Check djvups -orient=portrait failed."
    test -f djvups42.djvu
    CHECK_RESULT $? 0 0 "Check djvups42.ps not exist."
    djvups -mode=color test.djvu djvups5.djvu
    CHECK_RESULT $? 0 0 "Check djvups -mode=color failed."
    test -f djvups5.djvu
    CHECK_RESULT $? 0 0 "Check djvups5.ps not exist."
    djvups -zoom=25 test.djvu djvups6.djvu
    CHECK_RESULT $? 0 0 "Check djvups -zoom=25 failed."
    test -f djvups6.djvu
    CHECK_RESULT $? 0 0 "Check djvups6.ps not exist."
    djvups -bookletfold=18+200 test.djvu djvups7.djvu
    CHECK_RESULT $? 0 0 "Check djvups -bookletfold=18+200 failed."
    test -f djvups7.djvu
    CHECK_RESULT $? 0 0 "Check djvups7.ps not exist."
    djvups -booklet=no test.djvu djvups31.djvu
    CHECK_RESULT $? 0 0 "Check djvups -booklet=no failed."
    test -f djvups31.djvu
    CHECK_RESULT $? 0 0 "Check djvups31.ps not exist."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -v '\.sh')
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
