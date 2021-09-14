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
#@Author    	:   ycd21028
#@Contact   	:   1076964753@qq.com
#@Date      	:   2021-07-19 16:29:13
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   use the rpmlint command to check common errors in the rpm packages
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "rpmlint"
    wget https://repo.openeuler.org/openEuler-20.03-LTS/everything/aarch64/Packages/LibRaw-0.19.0-9.oe1.aarch64.rpm
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    # test rpm
    LOG_INFO "Start to run test1."
    rpmlint -i LibRaw-0.19.0-9.oe1.aarch64.rpm | grep -oE "[0-9]* packages and [0-9]* specfiles checked; [0-9]* errors, [0-9]* warnings."
    CHECK_RESULT $? 0 0 "rpmlint -i failed"
    LOG_INFO "End to run test1."

    # test -V
    LOG_INFO "Start to run test2."
    rpmlint -V | grep "rpmlint version 1.10 Copyright (C) 1999-2007 Frederic Lepied, Mandriva"
    CHECK_RESULT $? 0 0 "rpmlint -V failed"
    LOG_INFO "End to run test2."

    # test -C
    LOG_INFO "Start to run test3."
    rpmlint -C /root /home | grep -oE "[0-9]* packages and [0-9]* specfiles checked; [0-9]* errors, [0-9]* warnings."
    CHECK_RESULT $? 0 0 "rpmlint -C failed"
    LOG_INFO "End to run test3."

    # test spec
    LOG_INFO "Start to run test4."
    git clone https://gitee.com/src-openeuler/unzip.git
    rpmlint unzip/unzip.spec | grep -oE "[0-9]* packages and [0-9]* specfiles checked; [0-9]* errors, [0-9]* warnings."
    CHECK_RESULT $? 0 0 "rpmlint unzip.spec failed"
    LOG_INFO "End to run test4."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE 
    rm -rf LibRaw-0.19.0-9.oe1.aarch64.rpm unzip
    LOG_INFO "End to restore the test environment."
}

main "$@"

