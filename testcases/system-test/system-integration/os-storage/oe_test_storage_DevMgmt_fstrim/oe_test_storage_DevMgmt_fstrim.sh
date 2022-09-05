#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   DevMgmt fstrim
# ############################################

source ../common/storage_disk_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    local_lang=$LANG
    export LANG=en_US.utf-8
    check_free_disk
    mkdir -p /home/sdbpoint/
    DNF_INSTALL "multipath-tools"
    LOG_INFO "Start to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    mkfs.ext4 -F /dev/${local_disk}
    CHECK_RESULT $?
    fstrim --all
    CHECK_RESULT $?
    fstrim /dev/mapper/ | grep "fstrim: /dev/mapper/: the discard operation is not supported"
    CHECK_RESULT $? 1
    mount -o discard /dev/${local_disk} /home/sdbpoint
    CHECK_RESULT $?
    systemctl enable --now fstrim.timer
    CHECK_RESULT $?
    systemctl status fstrim.timer | grep "active"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to clean the test environment."
    umount /home/sdbpoint
    rm -rf /home/sdbpoint
    DNF_REMOVE
    export LANG=${local_lang}
    LOG_INFO "Start to clean the test environment."
}
main "$@"
