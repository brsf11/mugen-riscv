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
#@Desc      	:   Take the test soft link file
#####################################

source ../common_lib/fsio_lib.sh

function config_params() {
    LOG_INFO "Start parameters preparation."
    point_list=($(CREATE_FS))
    ext3_point=${point_list[1]}
    ext4_point=${point_list[2]}
    xfs_point=${point_list[3]}
    echo "test ext3" >$ext3_point/testFile
    mkdir -p $ext3_point/testDir/test1
    LOG_INFO "End of parameters preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    ln -s $ext3_point/testFile $ext4_point/testSoft1
    ln -s $ext3_point/testDir $ext4_point/testSoft2
    grep "ext3" $ext4_point/testSoft1
    CHECK_RESULT $? 0 0 "The sort link file on ext4 has some errors."
    ls $ext4_point/testSoft2 | grep "test1"
    CHECK_RESULT $? 0 0 "The sort link directory on ext4 has some errors."
    ln -s $ext3_point/testFile $xfs_point/testSoft3
    ln -s $ext3_point/testDir $xfs_point/testSoft4
    grep "ext3" $xfs_point/testSoft3
    CHECK_RESULT $? 0 0 "The sort link file on xfs has some errors."
    ls $xfs_point/testSoft4 | grep "test1"
    CHECK_RESULT $? 0 0 "The sort link directory on xfs has some errors."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    list=$(echo ${point_list[@]})
    REMOVE_FS "$list"
    LOG_INFO "End to restore the test environment."
}

main $@
