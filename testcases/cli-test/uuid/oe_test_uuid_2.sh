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
#@Author    	:   mcfd
#@Contact   	:   990773468@qq.com
#@Date      	:   2021-07-13 10:11:00
#@License   	:   Mulan PSL v2
#@Desc      	:   command test uuid
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh


function pre_test()
{
    LOG_INFO "Start to prepare the test environment."

    DNF_INSTALL "uuid"

    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    uuid
    CHECK_RESULT $? 0 0 "Err:uuid"
    uuid -v1
    CHECK_RESULT $? 0 0 "Err:uuid -v1"
    uuid -v3 ns:URL https://kernel.org
    CHECK_RESULT $? 0 0 "Err:uuid -v3 ns:URL https://kernel.org"
    uuid -v4
    CHECK_RESULT $? 0 0 "Err:uuid -v4"
    uuid -v5 ns:URL https://kernel.org
    CHECK_RESULT $? 0 0 "Err:uuid -v5 ns:URL https://kernel.org"
    uuid -m
    CHECK_RESULT $? 0 0 "Err:uuid -m"
    uuid -n2
    CHECK_RESULT $? 0 0 "Err:uuid -n2"
    uuid -n3 -1
    CHECK_RESULT $? 0 0 "Err:uuid -n3 -1"
    uuid -F bin
    CHECK_RESULT $? 0 0 "Err:uuid -F bin"
    uuid -F str
    CHECK_RESULT $? 0 0 "Err:uuid -F str"
    uuid -F siv
    CHECK_RESULT $? 0 0 "Err:uuid -F siv"
    uuid -o 1.txt
    wc -m 1.txt | grep 37 
    CHECK_RESULT $? 0 0 "Err:uuid -o 1.txt"
    test_num=$(uuid)
    uuid -d $test_num
    CHECK_RESULT $? 0 0 "Err:uuid -d "
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."

    rm -f 1.txt
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
