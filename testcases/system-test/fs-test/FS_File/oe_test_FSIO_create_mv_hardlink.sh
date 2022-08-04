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
#@Desc      	:   Take the test create and mv hard link file 
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    point_list=($(CREATE_FS "ext3 ext4"))
    ext3_point=${point_list[1]}
    ext4_point=${point_list[3]}
    echo "test ext3" > $ext3_point/testFile
    ln $ext3_point/testFile $ext3_point/testLink
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    ori_inode=$(stat $ext3_point/testLink | grep Inode | cut -d : -f 3 | awk '{print $1}')
    mv $ext3_point/testLink $ext3_point/testLink1
    inode1=$(stat $ext3_point/testLink1 | grep Inode | cut -d : -f 3 | awk '{print $1}')
    [[ "$ori_inode" == "$inode1" ]]
    CHECK_RESULT $? 0 0 "The hard link inode is changed unexpectly when mv on ext3"
    mv $ext3_point/testLink1 $ext4_point/testLink
    inode2=$(stat $ext4_point/testLink | grep Inode | cut -d : -f 3 | awk '{print $1}')
    [[ "$ori_inode" != "$inode2" ]]
    CHECK_RESULT $? 0 0 "The hard link inode doesn't change when mv from ext3 to ext4"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    list=$(echo ${point_list[@]})
    REMOVE_FS "$list"
    LOG_INFO "End to restore the test environment."
}

main $@
