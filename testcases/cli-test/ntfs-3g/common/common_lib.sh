#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wenjun
# @Contact   :   1009065695@qq.com
# @Date      :   2021-10-25
# @License   :   Mulan PSL v2
# @Desc      :   Enable periodic block discard
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function get_disk() {
    disks=$(TEST_DISK)
    disk_list=($disks)
    disk1=${disk_list[0]}
    disk2=${disk_list[1]}
    DNF_INSTALL ntfs-3g
    mkntfs --fast /dev/${disk1}
    mkntfs --fast /dev/${disk2}
}

function check_file_and_umount_disk() {
    disk=$1
    dir=$2
    file=$3
    ntfs-3g /dev/${disk} ${dir}
    test -f ${dir}/${file}
    CHECK_RESULT $? 0 0 "Check file failed."
    rm -rf ${dir}/${file}
    umount ${dir}
}
