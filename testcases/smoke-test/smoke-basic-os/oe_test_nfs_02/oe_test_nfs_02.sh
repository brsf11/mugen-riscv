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
# @Desc      :   Test showmount -e
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL nfs-utils
    cp /etc/exports /etc/exports.bak
    echo "/tmp/test *(fsid=0,rw,sync,all_squash)" >/etc/exports
    mkdir /tmp/test
    SLEEP_WAIT 3
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    exportfs -r
    CHECK_RESULT $? 0 0 "Load failed"
    systemctl restart nfs
    CHECK_RESULT $? 0 0 "Service restart failed"
    showmount -e | grep "/tmp/test"
    CHECK_RESULT $? 0 0 "Failed to execute showmount"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/test
    mv -f /etc/exports.bak /etc/exports
    exportfs -r
    systemctl stop nfs
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
