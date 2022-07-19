#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
#@Date      	:   2020-11-30
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test touch file without inode
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."
    point_list=($(CREATE_FS))
    for i in $(seq 1 $((${#point_list[@]} - 1))); do
        var=${point_list[$i]}
        free_space=$(($(df -i | grep $var | awk '{print $4}') + 1000))
        for i in $(seq 1 $free_space); do
            echo $i >$var/test$i &>/dev/null
        done
    done
    LOG_INFO "Finish to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."
    for i in $(seq 1 $((${#point_list[@]} - 1))); do
        var=${point_list[$i]}
        touch $var/testfile 2>&1 | grep "No space left on device"
        CHECK_RESULT $? 0 0 "Create file when $var doesn't have space unexpectly."
        sed -i "amodify" $var/test1 2>&1 | grep "No space left on device"
        CHECK_RESULT $? 0 0 "Modify file when $var doesn't have space failed."
        cp $var/test1 $var/testfile 2>&1 | grep "No space left on device"
        CHECK_RESULT $? 0 0 "Copy file when $var doesn't have space unexpectly."
        rm -f $var/test2
        CHECK_RESULT $? 0 0 "Remove file when $var doesn't have space failed."
    done

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    list=$(echo ${point_list[@]})
    REMOVE_FS "$list"
    LOG_INFO "End to restore the test environment."
}

main "$@"

