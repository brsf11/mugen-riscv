#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Desc      :   File system common command test-chown
# ############################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    tmpdir="/tmp/"$cur_date
    testdir=$tmpdir"/testdir"
    user="test"$cur_date
    useradd $user
    echo "testpasswd" | passwd $user --stdin
    mkdir -p $testdir
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    ls -l $tmpdir | tail -n 1 | awk '{print $3}' | grep "root"
    CHECK_RESULT $? 0 0 "Check user failed."
    ls -l $tmpdir | tail -n 1 | awk '{print $4}' | grep "root"
    CHECK_RESULT $? 0 0 "Check group failed."
    chown -R $user:$user $tmpdir
    CHECK_RESULT $? 0 0 "Execute chown -R failed."
    ls -l /tmp | grep $cur_date | awk '{print $3}' | grep $user
    CHECK_RESULT $? 0 0 "$tmpdir user change failed."
    ls -l /tmp | grep $cur_date | awk '{print $4}' | grep $user
    CHECK_RESULT $? 0 0 "$tmpdir group change failed."
    ls -l $tmpdir | tail -n 1 | awk '{print $3}' | grep $user
    CHECK_RESULT $? 0 0 "$testdir user change failed."
    ls -l $tmpdir | tail -n 1 | awk '{print $4}' | grep $user
    CHECK_RESULT $? 0 0 "$testdir group change failed."
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf $tmpdir
    userdel -r $user
    LOG_INFO "Finish environment cleanup!"
}

main $@
