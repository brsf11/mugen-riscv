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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/07/13
# @License   :   Mulan PSL v2
# @Desc      :   Test the mount function of NFS
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL nfs-utils
    cp /etc/exports /etc/exports.bak
    echo "/home/nfs *(rw,sync,all_squash)" >>/etc/exports
    mkdir /home/nfs /home/test
    exportfs -avr
    systemctl restart nfs
    chmod 777 /home/nfs
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mount -t nfs -o ro 127.0.0.1:/home/nfs /home/test
    CHECK_RESULT $? 0 0 "Mount failed"
    touch /home/test/test
    CHECK_RESULT $? 0 1 "Folder is not read-only"
    mount -o remount,rw /home/test
    CHECK_RESULT $? 0 0 "Failed to modify permission"
    touch /home/test/test
    CHECK_RESULT $? 0 0 "Folder is not write"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    umount /home/test
    rm -rf /home/nfs /home/test
    mv -f /etc/exports.bak /etc/exports
    exportfs -avr
    systemctl stop nfs
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
