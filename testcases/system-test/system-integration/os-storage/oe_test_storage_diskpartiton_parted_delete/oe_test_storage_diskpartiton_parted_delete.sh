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
# @Desc      :   Use parted shell to delete partition
# ############################################

source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    check_free_disk
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    echo "m\np\nn\np\n1\n\n+500M\np\nn\np\n2\n\n+500M\np\nn\np\n3\n\n+500M\np\nw\n" | fdisk /dev/${local_disk} >log1
    grep -iE "${local_disk}1|${local_disk}2|${local_disk}3" log1
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    echo -e "print\nrm 3\nprint\nquit\n" | parted /dev/${local_disk} >log2
    CHECK_RESULT $?
    lsblk | grep ${local_disk}3
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    SLEEP_WAIT 2
    echo -e "d\n1\nd\n2\nd\nw\n" | fdisk /dev/${local_disk}
    rm -rf log1 log2
    LOG_INFO "Finish environment cleanup."
}

main "$@"
