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
# @Desc      :   Test the basic functions of exportfs
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL nfs-utils
    cp -f /etc/exports /etc/exports.bak
    echo "/tmp/test ${NODE1_IPV4}(fsid=0,rw,sync)" >/etc/exports
    mkdir /tmp/test
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    exportfs -r
    CHECK_RESULT $? 0 0 "Load failed"
    exportfs -v | grep "${NODE1_IPV4}"
    CHECK_RESULT $? 0 0 "Failed to display ipv4"
    exportfs -u ${NODE1_IPV4}:/tmp/test
    CHECK_RESULT $? 0 0 "Unload failed"
    exportfs -v | grep "${NODE1_IPV4}"
    CHECK_RESULT $? 0 1 "Succeed to display ipv4"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    exportfs -au
    rm -rf /tmp/test
    mv -f /etc/exports.bak /etc/exports
    exportfs -r
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
