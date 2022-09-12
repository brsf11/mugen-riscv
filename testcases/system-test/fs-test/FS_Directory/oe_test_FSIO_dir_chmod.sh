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
#@Contact   	:   bubble_mt@outlook.com
#@Date      	:   2020-11-23
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test chmod
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    point_list=($(CREATE_FS))
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    for i in $(seq 1 $((${#point_list[@]} - 1))); do
        var=${point_list[$i]}
        mkdir -p $var/tmp/test01/test02/test03
        per01=$(ls -l $var/tmp | grep "test01" | awk '{print $1}')
        per02=$(ls -l $var/tmp/test01 | grep "test02" | awk '{print $1}')
        [[ "$per01" =~ "drwxr-xr-x" ]]
        CHECK_RESULT $? 0 0 "Check access of $var/tmp failed when creating defualt."
        chmod 777 $var/tmp/test01
        per03=$(ls -l $var/tmp | grep "test01" | awk '{print $1}')
        per04=$(ls -l $var/tmp/test01 | grep "test02" | awk '{print $1}')
        [[ "$per03" =~ "drwxrwxrwx" ]]
        CHECK_RESULT $? 0 0 "Check access of $var/tmp failed."
        [ "$per02" == "$per04" ]
        CHECK_RESULT $? 0 0 "Check access of $var/tmp/test01 failed."
        chmod -R 777 $var/tmp/test01
        per05=$(ls -l $var/tmp/ | grep "test01" | awk '{print $1}')
        per06=$(ls -l $var/tmp/test01 | grep "test02" | awk '{print $1}')
        [[ "$per05" =~ "drwxrwxrwx" ]]
        CHECK_RESULT $? 0 0 "Check access of $var/tmp failed."
        [[ "$per06" =~ "drwxrwxrwx" ]]
        CHECK_RESULT $? 0 0 "Check access of $var/tmp/test01 failed."
    done
    chmod --help | grep "Usage"
    CHECK_RESULT $? 0 0 "Check help failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    list=$(echo ${point_list[@]})
    REMOVE_FS "$list"
    LOG_INFO "End to restore the test environment."
}

main $@

