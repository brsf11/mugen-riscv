#!/usr/bin/bash

# Copyright (c) 2022.Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-chmod
# ############################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    testdir="test01"$cur_date
    ls /tmp/$testdir && rm -rf /tmp/$testdir
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to test."
    mkdir -p /tmp/$testdir/test02/test03
    per01=$(ls -l /tmp | grep "$testdir" | awk '{print $1}')
    per02=$(ls -l /tmp/$testdir | grep "test02" | awk '{print $1}')
    [[ "$per01" =~ "drwxr-xr-x" ]]
    CHECK_RESULT $? 0 0 "The access of /tmp is error."
    chmod 777 /tmp/$testdir
    per03=$(ls -l /tmp | grep "$testdir" | awk '{print $1}')
    per04=$(ls -l /tmp/$testdir | grep "test02" | awk '{print $1}')
    [[ "$per03" =~ "drwxrwxrwx" ]]
    CHECK_RESULT $? 0 0 "The access of /tmp is error."
    [ "$per02" == "$per04" ]
    CHECK_RESULT $? 0 0 "The access of /tmp/$testdir is error."
    chmod -R 777 /tmp/$testdir
    per05=$(ls -l /tmp/ | grep "$testdir" | awk '{print $1}')
    per06=$(ls -l /tmp/$testdir | grep "test02" | awk '{print $1}')
    [[ "$per05" =~ "drwxrwxrwx" ]]
    CHECK_RESULT $? 0 0 "The access of /tmp is error."
    [[ "$per06" =~ "drwxrwxrwx" ]]
    CHECK_RESULT $? 0 0 "The access of /tmp/$testdir is error."
    chmod --help | grep "Usage"
    CHECK_RESULT $? 0 0 "The chmode help usage is error."
    LOG_INFO "End to test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /tmp/$testdir
    LOG_INFO "Finish environment cleanup!"
}

main $@
