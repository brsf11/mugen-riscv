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
#@Author    	:   ice-kylin
#@Contact   	:   wminid@yeah.net
#@Date      	:   2021-07-24
#@License   	:   Mulan PSL v2
#@Desc      	:   command test mksh
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "mksh"
    echo 'echo $-' > ./test1.sh
    echo 'cd /' > ./test2.sh
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    mksh './test1.sh' | grep -v i
    CHECK_RESULT $? 0 0 "log message: Failed to run command: mksh './test1.sh' | grep -v i"
    mksh -c 'echo "Hello World"' | grep "Hello World"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: mksh -c 'echo \"Hello World\"' | grep \"Hello World\""
    mksh -i './test1.sh' | grep i
    CHECK_RESULT $? 0 0 "log message: Failed to run command: mksh -i './test1.sh' | grep i"
    mksh -l './test1.sh' | grep l
    CHECK_RESULT $? 0 0 "log message: Failed to run command: mksh -l './test1.sh' | grep l"
    mksh -cp 'echo "Hello World"' | grep "Hello World"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: mksh -cp 'echo \"Hello World\"' | grep \"Hello World\""
    mksh -r './test2.sh'
    CHECK_RESULT $? 2 0 "log message: Failed to run command: mksh -r './test2.sh'"
    echo "echo 'Hello World'" | mksh -s
    CHECK_RESULT $? 0 0 "log message: Failed to run command: echo \"echo 'Hello World'\" | mksh -s"
    lksh './test1.sh' | grep -v i
    CHECK_RESULT $? 0 0 "log message: Failed to run command: lksh './test1.sh' | grep -v i"
    lksh -c 'echo "Hello World"' | grep "Hello World"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: lksh -c 'echo \"Hello World\"' | grep \"Hello World\""
    lksh -i './test1.sh' | grep i
    CHECK_RESULT $? 0 0 "log message: Failed to run command: lksh -i './test1.sh' | grep i"
    lksh -l './test1.sh' | grep l
    CHECK_RESULT $? 0 0 "log message: Failed to run command: lksh -l './test1.sh' | grep l"
    lksh -cp 'echo "Hello World"' | grep "Hello World"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: lksh -cp 'echo \"Hello World\"' | grep \"Hello World\""
    lksh -r './test2.sh'
    CHECK_RESULT $? 2 0 "log message: Failed to run command: lksh -r './test2.sh'"
    echo "echo 'Hello World'" | lksh -s
    CHECK_RESULT $? 0 0 "log message: Failed to run command: echo \"echo 'Hello World'\" | lksh -s"
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./test1.sh ./test2.sh
    LOG_INFO "End to restore the test environment."
}

main "$@"
