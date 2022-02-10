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
# @Desc      :   Use fdisk to set the partition type
# ############################################

source ../common/storage_disk_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    check_free_disk
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    echo -e "m\np\nn\np\n1\n2048\n+1G\np\nn\np\n2\n\n+500M\np\nw\n" | fdisk /dev/${local_disk} >log1
    grep -iE "${local_disk}1|${local_disk}2" log1 | wc -l | grep 3
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    echo -e "print\ntype\n2\nL\n1\nw\n" | fdisk /dev/${local_disk} >log2
    CHECK_RESULT $?

    fdisk --list /dev/${local_disk} | grep ${local_disk}2 | awk -F " " '{print$7}' | grep -i fat
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    SLEEP_WAIT 2
    echo -e "m\np\nd\n1\nd\nw\n" | fdisk /dev/${local_disk}
    SLEEP_WAIT 2
    rm -rf log1 log2
    LOG_INFO "Finish environment cleanup."
}

main "$@"
