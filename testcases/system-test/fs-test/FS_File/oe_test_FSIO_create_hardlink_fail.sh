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
#@Date      	:   2020-12-01
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test create hard link file failed
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    point_list=($(CREATE_FS "ext3 ext4 xfs"))
    ext3_point=${point_list[1]}
    ext4_point=${point_list[2]}
    xfs_point=${point_list[3]}
    echo "test ext3" >$ext3_point/testFile1
    echo "test ext4" >$ext4_point/testFile1
    echo "test xfs" >$xfs_point/testFile1
    mkdir $ext3_point/testDir
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    ln $ext3_point/testDir /tmp/hard_link$cur_date 2>&1 | grep "hard link not allowed for directory"
    CHECK_RESULT $? 0 0 "Create hard link for directory unexpectly."
    ln $ext3_point/testnonexist /tmp/hard_link$cur_date 2>&1 | grep "No such file or directory"
    CHECK_RESULT $? 0 0 "Create hard link for non-exist directory unexpectly."
    ln $ext3_point/testFile1 $ext4_point/hardFile 2>&1 | grep "Invalid cross-device link"
    CHECK_RESULT $? 0 0 "Create hard link between ext3 and ext4 unexpectly."
    ln $ext4_point/testFile1 $xfs_point/hardFile 2>&1 | grep "Invalid cross-device link"
    CHECK_RESULT $? 0 0 "Create hard link between ext4 and xfs unexpectly."
    ln $xfs_point/testFile1 $ext3_point/hardFile 2>&1 | grep "Invalid cross-device link"
    CHECK_RESULT $? 0 0 "Create hard link between xfs and ext3 unexpectly."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    list=$(echo ${point_list[@]})
    REMOVE_FS "$list"
    LOG_INFO "End to restore the test environment."
}

main $@
