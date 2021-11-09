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
#@Date          :   2021-08-13 12:00:43
#@License   	:   Mulan PSL v2
#@Desc          :   verification groovy's commnd
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL groovy
    cp ../common/test.groovy ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    groovyc -d /tmp/ test.groovy
    CHECK_RESULT $? 0 0 "Check groovyc -d failed."
    test -f /tmp/test.class && rm -rf /tmp/test.class
    CHECK_RESULT $? 0 0 "Check groovyc -d failed."
    groovyc test.groovy
    CHECK_RESULT $? 0 0 "Check groovyc failed."
    test -f test.class && rm -rf test.class
    groovyc -e test.groovy
    CHECK_RESULT $? 0 0 "Check groovyc -e failed."
    test -f test.class && rm -rf test.class
    CHECK_RESULT $? 0 0 "Check groovyc -e failed."
    groovyc -cp lib/dep.jar test.groovy
    CHECK_RESULT $? 0 0 "Check groovyc -cp failed."
    test -f test.class && rm -rf test.class
    CHECK_RESULT $? 0 0 "Check groovyc -cp failed."
    groovyc --encoding utf-8 test.groovy
    CHECK_RESULT $? 0 0 "Check groovyc --encoding failed."
    test -f test.class && rm -rf test.class
    CHECK_RESULT $? 0 0 "Check groovyc --encoding failed."
    groovyc --indy test.groovy
    CHECK_RESULT $? 0 0 "Check groovyc --indy failed."
    test -f test.class
    CHECK_RESULT $? 0 0 "Check test.class not exist."
    groovy test | grep "15"
    CHECK_RESULT $? 0 0 "Check groovy failed."
    test -f test.class && rm -rf test.class
    CHECK_RESULT $? 0 0 "Check groovy failed."
    groovydoc --help | grep "usage: groovydoc"
    CHECK_RESULT $? 0 0 "Check groovydoc --help failed."
    groovydoc --version | grep "GroovyDoc"
    CHECK_RESULT $? 0 0 "Check groovydoc --version failed."
    groovydoc test.groovy
    CHECK_RESULT "$(ls ./ | wc -w)" 14
    groovydoc -d /tmp ./test.groovy
    CHECK_RESULT $? 0 0 "Check groovydoc -d failed."
    CHECK_RESULT "$(ls /tmp/ | wc -w)" 15
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -v '\.sh') /tmp/*
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
