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
#@Date      	:   2020-12-02
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test zip/unzip on same fs
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    point_list=($(CREATE_FS))
    for i in $(seq 1 $((${#point_list[@]} - 1))); do
        var=${point_list[$i]}
        mkdir $var/testDir $var/testDir2
        echo "test file" >$var/testDir/testFile
    done
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    for i in $(seq 1 $((${#point_list[@]} - 1))); do
        var=${point_list[$i]}
        zip -r $var/testdir.zip $var/testDir
        CHECK_RESULT $? 0 0 "Compress file by zip in $var failed."
        unzip -l $var/testdir.zip | grep "testDir/testFile"
        CHECK_RESULT $? 0 0 "Check file on zip in $var failed."
        unzip $var/testdir.zip
        ls $var/testDir | grep "testFile"
        CHECK_RESULT $? 0 0 "Decompress file by zip in $var failed."
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
