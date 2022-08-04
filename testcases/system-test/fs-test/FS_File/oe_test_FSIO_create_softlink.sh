#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
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
#@Date      	:   2020-12-01
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test soft link file
#####################################

source ../common_lib/fsio_lib.sh

function config_params() {
    LOG_INFO "Start parameters preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    file="testFile"$cur_date
    dir="testDir"$cur_date
    soft_file="softFile"$cur_date
    soft_dir="softDir"$cur_date
    LOG_INFO "End of parameters preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    ln -s /tmp/$file /tmp/$soft_file
    ln -s /tmp/$dir /tmp/$soft_dir
    cat /tmp/$soft_file 2>&1 | grep "No such file or directory"
    CHECK_RESULT $? 0 0 "The sort link file has some errors."
    cat /tmp/$soft_dir 2>&1 | grep "No such file or directory"
    CHECK_RESULT $? 0 0 "The sort link directory has some errors."
    echo "test file" >/tmp/$file
    mkdir -p /tmp/$dir/testdir
    grep "test" /tmp/$soft_file
    CHECK_RESULT $? 0 0 "The sort link file has some errors."
    ls /tmp/$soft_dir | grep "testdir"
    CHECK_RESULT $? 0 0 "The sort link directory has some errors."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/$soft_file /tmp/$soft_dir /tmp/$file /tmp/$dir
    LOG_INFO "End to restore the test environment."
}

main $@
