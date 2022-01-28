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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   Use partedshell to create a partition
# ############################################
source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    check_free_disk 
    mkfs.ext4 -F /dev/${local_disk}
    LOG_INFO "Loading data is complete!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    expect -c "
spawn parted /dev/${local_disk} mklabel gpt
expect \"Yes\/No*\" 
send \"yes\r\"
expect eof
"
    parted /dev/${local_disk} mkpart primary 200MiB 400MiB
    CHECK_RESULT $?
    lsblk | grep ${local_disk}1 | grep "200M"
    CHECK_RESULT $?
    udevadm settle
    CHECK_RESULT $?
    grep ${local_disk}1 /proc/partitions
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    echo -e "m\np\nd\nw\n" | fdisk /dev/${local_disk}
    LOG_INFO "Finish environment cleanup."
}

main "$@"
