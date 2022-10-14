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
#@Desc      	:   Take the test tar
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL tar
    cur_date=$(date +%Y%m%d%H%M%S)
    point_list=($(CREATE_FS))
    testFile1="testFile1$cur_date"
    testFile2="testFile2$cur_date"
    testFile3="testFile3$cur_date"
    for i in $(seq 1 $((${#point_list[@]} - 1))); do
        var=${point_list[$i]}
        echo "test file 1" >$var/$testFile1
        echo "test file 2" >$var/$testFile2
        echo "test file 3" >$var/$testFile3
    done
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    for i in $(seq 1 $((${#point_list[@]} - 1))); do
        var=${point_list[$i]}
        testTar="$var/testTar$cur_date.tar"
        tar -Pcf $testTar $var/$testFile1 $var/$testFile2 $var/$testFile3
        CHECK_RESULT $? 0 0 "Compress file by tar in $var failed."
        tar -Ptvf $testTar | grep "testFile1"
        CHECK_RESULT $? 0 0 "Check files in tar in $var failed."
        tar -Pxvf $testTar
        CHECK_RESULT $? 0 0 "Decompress file by tar in $var failed."
    done
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    list=$(echo ${point_list[@]})
    REMOVE_FS "$list"
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main $@
