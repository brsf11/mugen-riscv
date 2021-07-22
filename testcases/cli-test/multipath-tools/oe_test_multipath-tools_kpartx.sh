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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/10/20
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in kpartx binary package
# ############################################

source "common_multipath-tools.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    local_disks=$(TEST_DISK 1)
    local_disk=$(echo $local_disks | awk -F " " '/sd[a-z]/ {for(i=1;i<=NF;i++) if ($i~/sd/ && $i!~/[0-9]/)j=i;print $j}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    kpartx -a -f -v /dev/${local_disk} | grep " map ${local_disk}1"
    CHECK_RESULT $?
    kpartx -u /dev/${local_disk}
    CHECK_RESULT $?
    lsblk | grep ${local_disk}1
    CHECK_RESULT $?
    kpartx -l /dev/${local_disk} | grep "${local_disk}1"
    CHECK_RESULT $?
    kpartx -n /dev/${local_disk} | grep "${local_disk}1"
    CHECK_RESULT $?
    kpartx -s /dev/${local_disk} | grep "/dev/${local_disk}"
    CHECK_RESULT $?
    kpartx -g /dev/${local_disk} | grep "${local_disk}"
    CHECK_RESULT $?
    kpartx -p p /dev/${local_disk} | grep "${local_disk}p"
    CHECK_RESULT $?
    kpartx -r /dev/${local_disk} | grep "${local_disk}"
    CHECK_RESULT $?
    kpartx -d /dev/${local_disk}
    CHECK_RESULT $?
    ls -l /dev/mapper/ | grep "${local_disk}1 \-> "
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
