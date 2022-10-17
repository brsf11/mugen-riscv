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
#@Desc      	:   Take the test zip/unzip on different fs
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    point_list=($(CREATE_FS "ext3 ext4 xfs"))
    ext3_point=${point_list[1]}
    ext4_point=${point_list[2]}
    xfs_point=${point_list[3]}
    mkdir $ext3_point/testDir1 $ext3_point/testDir2
    echo "test file" >$ext3_point/testDir1/testFile
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    zip -r $ext4_point/test1.zip $ext3_point/testDir1
    CHECK_RESULT $? 0 0 "Compress file by zip from ext3 to ext4 failed."
    unzip -l $ext4_point/test1.zip | grep "testFile"
    CHECK_RESULT $? 0 0 "Check file on zip in ext4 failed."
    unzip $ext4_point/test1.zip -d $ext4_point
    CHECK_RESULT $? 0 0 "Decompress file by zip in ext4 failed."
    zip -r $xfs_point/test2.zip $ext3_point/testDir1
    CHECK_RESULT $? 0 0 "Compress file by zip from ext3 to xfs failed."
    unzip -l $xfs_point/test2.zip | grep "testFile"
    CHECK_RESULT $? 0 0 "Check file on zip in xfs failed."
    unzip $xfs_point/test2.zip -d $xfs_point
    CHECK_RESULT $? 0 0 "Decompress file by zip in xfs failed."
    zip -r $xfs_point/test3.zip $ext4_point/$ext3_point/testDir1
    CHECK_RESULT $? 0 0 "Compress file by zip from ext4 to xfs failed."
    unzip -l $xfs_point/test3.zip | grep "testFile"
    CHECK_RESULT $? 0 0 "Check file on zip in xfs failed."
    unzip $xfs_point/test3.zip -d $xfs_point
    CHECK_RESULT $? 0 0 "Decompress file by zip in xfs failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    list=$(echo ${point_list[@]})
    REMOVE_FS "$list"
    LOG_INFO "End to restore the test environment."
}

main $@
