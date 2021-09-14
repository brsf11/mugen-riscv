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
#@Author        :   ycd21028
#@Contact       :   1076964753@qq.com
#@Date          :   2021-07-19 17:40:43
#@License       :   Mulan PSL v2
#@Version       :   1.0
#@Desc          :   use the rpmdiff command to check common errors in the rpm packages
#####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rpmlint
    wget https://repo.openeuler.org/openEuler-20.03-LTS/everything/aarch64/Packages/LibRaw-0.19.0-9.oe1.aarch64.rpm
    wget https://repo.openeuler.org/openEuler-20.03-LTS/update/aarch64/Packages/LibRaw-0.19.0-10.oe1.aarch64.rpm
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    # normal
    LOG_INFO "Start to run test1."
    rpmdiff LibRaw-0.19.0-10.oe1.aarch64.rpm LibRaw-0.19.0-9.oe1.aarch64.rpm | grep "S.5.......T /usr/lib64/libraw.so.19.0.0"
    CHECK_RESULT $? 0 0 "rpmdiff failed"
    LOG_INFO "End to run test1."

    # ignore 5(checksum)
    LOG_INFO "Start to run test2."
    rpmdiff -i 5 LibRaw-0.19.0-10.oe1.aarch64.rpm LibRaw-0.19.0-9.oe1.aarch64.rpm | grep "S.........T /usr/lib64/libraw.so.19.0.0"
    CHECK_RESULT $? 0 0 "rpmdiff -i 5 failed"
    LOG_INFO "End to run test2."

    # ignore T(time)
    LOG_INFO "Start to run test3."
    rpmdiff -i T LibRaw-0.19.0-10.oe1.aarch64.rpm LibRaw-0.19.0-9.oe1.aarch64.rpm | grep "S.5........ /usr/lib64/libraw.so.19.0.0"
    CHECK_RESULT $? 0 0 "rpmdiff -i T failed"
    LOG_INFO "End to run test3."

}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE 
    rm -rf LibRaw-0.19.0-10.oe1.aarch64.rpm LibRaw-0.19.0-9.oe1.aarch64.rpm
    LOG_INFO "End to restore the test environment."
}

main "$@"
