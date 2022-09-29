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
# @Date      :   2022/07/18
# @License   :   Mulan PSL v2
# @Desc      :   Test aide compare database
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL aide
    sed -i '88,176s/^/#/g' /etc/aide.conf
    echo "database_new=file:@@{DBDIR}/aide.db.new.gz" >>/etc/aide.conf
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    aide --init
    CHECK_RESULT $? 0 0 "initialization failed"
    cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    aide --compare >testlog
    CHECK_RESULT $? 0 0 "Comparison execution failed"
    grep -E "aide.db.gz|aide.db.new.gz" testlog
    CHECK_RESULT $? 0 0 "Comparison execution failed"
    diff testlog /var/log/aide/aide.log
    CHECK_RESULT $? 0 0 "Different file contents"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf testlog /var/log/aide/aide.log /var/lib/aide/aide*
    LOG_INFO "End to restore the test environment."
}

main "$@"
