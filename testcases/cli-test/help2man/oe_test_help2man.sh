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
#@Author    	:   ice-ktlin
#@Contact   	:   wminid@yeah.net
#@Date      	:   2021-07-14 23:33:33
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   command test help2man
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."

    DNF_INSTALL "help2man"

    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."

    help2man --help | grep "Usage: help2man"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man --help"

    help2man --version | egrep -o "GNU help2man [0-9.]{1,}"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man --version"

    help2man -n example echo | grep "echo \\\- example"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man -n example echo"

    help2man -s 8 echo | grep "ECHO \"8\""
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man -s 8 echo"

    help2man -S FSF echo | grep "FSF"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man-S FSF echo"

    help2man -m manname echo | grep "manname"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man -m manname echo"

    help2man -L C help2man
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man -L C help2man"

    echo '[TEST]
The quick brown fox jumps over the lazy dog.' > ./additional.h2m

    help2man -i ./additional.h2m help2man
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man -i ./additional.h2m help2man"

    help2man -I does_not_exist.h2m help2man
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man -I does_not_exist.h2m help2man"

    help2man -p infoname echo | grep "info infoname"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man -p infoname echo"

    help2man -N echo | grep info
    CHECK_RESULT $? 1 0 "log message: Failed to run command: help2man -N echo"

    help2man -l echo | grep "lt"
    CHECK_RESULT $? 1 0 "log message: Failed to run command: help2man -l echo"

    help2man -h helpstr echo | grep "DESCRIPTION"$'\n'"helpstr"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man -h helpstr echo"

    help2man -v versionstr echo | grep "manual page for echo versionstr"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man -v versionstr echo"

    help2man --version-string='test' help2man
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man --version-string='test' help2man"

    help2man --no-discard-stderr echo | grep dis
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man --no-discard-stderr echo"

    help2man -o ./help2man.1 help2man
    file ./help2man.1 | grep -E '(ASCII text|UTF-8 Unicode text)' && grep '\.\\" DO NOT MODIFY THIS FILE!' help2man.1
    CHECK_RESULT $? 0 0 "log message: Failed to run command: help2man -o ./help2man.1 help2man"

    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE
    rm -rf ./additional.h2m ./help2man.1 

    LOG_INFO "End to restore the test environment."
}

main "$@"
