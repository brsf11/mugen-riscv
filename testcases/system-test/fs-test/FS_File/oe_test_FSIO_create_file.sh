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
#@Date      	:   2020-11-30
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test create file on fs
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    point_list=($(CREATE_FS))
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    for i in $(seq 1 $((${#point_list[@]} - 1))); do
        var=${point_list[$i]}
        echo "test" >$var/testFile
        CHECK_RESULT $? 0 0 "Create file in $var failed."
        cat $var/testFile | grep "test"
        CHECK_RESULT $? 0 0 "Cat file in $var failed."
        sed -i "add" $var/testFile
        mv $var/testFile $var/testFile1
        cat $var/testFile1 | grep "dd"
        CHECK_RESULT $? 0 0 "Cat file in $var failed."
        rm -rf $var/testFile1
        cat $var/testFile1 2>&1 | grep "No such file or directory"
        CHECK_RESULT $? 0 0 "Remove file in $var failed."
    done
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    list=$(echo ${point_list[@]})
    REMOVE_FS "$list"
    LOG_INFO "End to restore the test environment."
}

main $@
