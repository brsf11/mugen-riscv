#!/usr/bin/bash

# Copyright (c) 2022.Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   @meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2020-12-02
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test chattr for file
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    testFile="/mnt/testFile$cur_date"
    touch $testFile
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    chattr +a $testFile
    CHECK_RESULT $? 0 0 "Change attribution +a of file failed."
    rm -f $testFile 2>&1 | grep "Operation not permitted"
    CHECK_RESULT $? 0 0 "Remove file which is +a unexpectly."
    chattr -a $testFile
    CHECK_RESULT $? 0 0 "Change attribution -a of file failed."
    rm -f $testFile
    CHECK_RESULT $? 0 0 "Remove file failed."
    LOG_INFO "End to run test."
}

main $@
