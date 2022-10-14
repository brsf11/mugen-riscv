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
#@Date      	:   2020-11-30
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test check /sys/fs
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    vggroup=$(CREATE_VG)
    ext4_point=/tmp/ext4$cur_date
    lvcreate -n "test_lv1"$cur_date -L 2G $vggroup -y >/dev/null
    mkfs.ext4 /dev/$vggroup/test_lv1$cur_date >/dev/null
    mkdir $ext4_point
    origin=$(ls /sys/fs/ext4 | wc -l)
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    mount /dev/$vggroup/test_lv1$cur_date $ext4_point >/dev/null
    CHECK_RESULT $? 0 0 "Mount failed."
    actual=$(ls /sys/fs/ext4 | wc -l)
    change=$(($actual-$origin))
    CHECK_RESULT $change 1 0 "Check change failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    umount -f $ext4_point
    LOG_INFO "End to restore the test environment."
}

main $@
