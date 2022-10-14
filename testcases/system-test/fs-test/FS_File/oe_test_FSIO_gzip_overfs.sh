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
#@Desc      	:   Take the test gzip over fs
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    point_list=($(CREATE_FS "ext3 ext4 xfs"))
    ext3_point=${point_list[1]}
    ext4_point=${point_list[2]}
    xfs_point=${point_list[3]}
    echo "test file ext3" >$ext3_point/testFile1
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    gzip -c $ext3_point/testFile1 > $ext4_point/testFile1.gz
    ls $ext4_point | grep "testFile1.gz"
    CHECK_RESULT $? 0 0 "Compress file by gzip in $ext4_point failed."
    gzip -dv $ext4_point/testFile1.gz > $ext3_point/testFile2
    ls $ext3_point | grep "testFile2"
    CHECK_RESULT $? 0 0 "Decompress gzip file in $ext3_point failed."
    gzip -c $ext3_point/testFile1 > $xfs_point/testFile1.gz
    ls $xfs_point | grep "testFile1.gz"
    CHECK_RESULT $? 0 0 "Compress file by gzip in $xfs_point failed."
    gzip -dv $xfs_point/testFile1.gz > $ext3_point/testFile3
    ls $ext3_point | grep "testFile3"
    CHECK_RESULT $? 0 0 "Decompress gzip file in $ext3_point failed."
    gzip -c $ext4_point/testFile1 > $xfs_point/testFile2.gz
    ls $xfs_point | grep "testFile2.gz"
    CHECK_RESULT $? 0 0 "Compress file by gzip in $xfs_point failed."
    gzip -dv $xfs_point/testFile2.gz > $ext4_point/testFile2
    ls $ext4_point | grep "testFile2"
    CHECK_RESULT $? 0 0 "Decompress gzip file in $ext4_point failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    list=$(echo ${point_list[@]})
    REMOVE_FS "$list"
    LOG_INFO "End to restore the test environment."
}

main $@
