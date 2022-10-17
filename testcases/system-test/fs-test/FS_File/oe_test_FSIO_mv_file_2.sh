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
#@Date      	:   2020-12-01
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test mv file on fs
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    point_list=($(CREATE_FS "ext3 ext4 xfs"))
    ext3_point=${point_list[1]}
    ext4_point=${point_list[2]}
    xfs_point=${point_list[3]}
    echo "test ext3 file" >$ext3_point/testFile1
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    mv $ext3_point/testFile1 $ext4_point/testFile2
    stat $ext4_point/testFile2 | grep "Inode"
    CHECK_RESULT $? 0 0 "Check inode of file $ext4_point/testFile2 failed."
    grep "test" $ext4_point/testFile2
    CHECK_RESULT $? 0 0 "Check file msg of $ext4_point/testFile2 failed."
    mv $ext4_point/testFile2 $xfs_point/testFile3
    stat $xfs_point/testFile3 | grep "Inode"
    CHECK_RESULT $? 0 0 "Check inode of file $xfs_point/testFile3 failed."
    grep "test" $xfs_point/testFile3
    CHECK_RESULT $? 0 0 "Check file msg of $xfs_point/testFile3 failed."
    mv $xfs_point/testFile3 $ext3_point/testFile4
    stat $ext3_point/testFile4 | grep "Inode"
    CHECK_RESULT $? 0 0 "Check inode of file $ext3_point/testFile4 failed."
    grep "test" $ext3_point/testFile4
    CHECK_RESULT $? 0 0 "Check file msg of $ext3_point/testFile4 failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    list=$(echo ${point_list[@]})
    REMOVE_FS "$list"
    LOG_INFO "End to restore the test environment."
}

main $@

