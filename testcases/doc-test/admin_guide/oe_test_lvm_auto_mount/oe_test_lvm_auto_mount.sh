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
# @Author    :   duanxuemin
# @Contact   :   52515856@qq.com
# @Date      :   2020-04-27
# @License   :   Mulan PSL v2
# @Desc      :   Execute the blkid command to query the UUID of the logical volume
# ############################################
source ../common/disk_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    check_free_disk
    pvcreate -y /dev/${local_disk} /dev/${local_disk1}
    vgcreate -y vg1 /dev/${local_disk} /dev/${local_disk1}
    lvcreate -y -L 2G -n lv1 vg1
    mkfs.ext4 /dev/vg1/lv1
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    mkdir /tmp/test
    blkid /dev/vg1/lv1
    CHECK_RESULT $?
    lv_uuid=$(blkid /dev/vg1/lv1 | awk -F "\"" '{print$2}')
    echo "UUID=${lv_uuid} /tmp/test ext4 defaults 0 0" >>/etc/fstab
    mount -a
    lsblk | grep vg1-lv1 | grep "/tmp/test"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /tmp/test
    rm -rf /tmp/test
    lvremove /dev/vg1/lv1 -y
    vgremove /dev/vg1
    pvremove /dev/${local_disk} /dev/${local_disk1}
    sed -i "/$lv_uuid/d" /etc/fstab
    LOG_INFO "Finish environment cleanup."
}

main $@
