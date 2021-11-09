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
#@Date          :   2021-08-13 09:00:43
#@License   	:   Mulan PSL v2
#@Desc          :   verification groovy's commnd
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL groovy
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    grape help | grep "usage: grape"
    CHECK_RESULT $? 0 0 "Check grape help failed."
    grape --help | grep "usage: grape"
    CHECK_RESULT $? 0 0 "Check grape --help failed."
    grape -v | grep "Version:"
    CHECK_RESULT $? 0 0 "Check grape -v failed."
    grape list | grep -E "Grape module versions cached|Grape modules cached"
    CHECK_RESULT $? 0 0 "Check grape list failed."
    groovyConsole --help | grep "usage: groovyConsole"
    CHECK_RESULT $? 0 0 "Check groovyConsole --help failed."
    groovy --help | grep "usage: groovy"
    CHECK_RESULT $? 0 0 "Check groovy --help failed."
    groovy -v | grep "Groovy Version"
    CHECK_RESULT $? 0 0 "Check groovy -v failed."
    groovy -e "println 'hello'" | grep "hello"
    CHECK_RESULT $? 0 0 "Check groovy -e failed."
    groovy -e "new File('.').eachFileRecurse {println it}" | grep "oe_test_groovy_01.sh"
    CHECK_RESULT $? 0 0 "Check groovy -e failed."
    groovyc --help | grep "usage: groovyc"
    CHECK_RESULT $? 0 0 "Check groovyc --help failed."
    groovyc -version 0 0 "Check groovyc --version failed."
    CHECK_RESULT $?
    expect <<-END
    spawn groovysh
    send ":help\n"
    expect "groovy:000>"
    send ":display\n"
    expect "groovy:000>"
    send ":history\n"
    expect "groovy:000>"
    send ":quit\n"
    expect eof
END
    pwd
    CHECK_RESULT $? 0 0 "Check groovysh failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
