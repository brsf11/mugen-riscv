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
# @Date      :   2020/11/10
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in pcp-import-sar2pcp binary package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "pcp-import-sar2pcp sysstat"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    sadc=$(rpm -ql sysstat | grep "/sa/sadc")
    $sadc 1 10 datafile
    CHECK_RESULT $?
    test -f datafile
    CHECK_RESULT $?
    sar2pcp datafile datapcp
    CHECK_RESULT $?
    grep -aE "localhost|UTC|8" datapcp.index
    CHECK_RESULT $?
    test -f datapcp.0 -a -f datapcp.meta && rm -rf datapcp.0 datapcp.meta datapcp.index
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf datafile
    LOG_INFO "End to restore the test environment."
}

main "$@"
