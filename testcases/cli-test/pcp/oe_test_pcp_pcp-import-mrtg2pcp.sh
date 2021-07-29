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
# @Desc      :   The usage of commands in pcp-import-mrtg2pcp binary package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "pcp-import-mrtg2pcp mrtg"
    disk_list=($(lsblk | awk '{print$1" "$6}' | grep disk | awk '{print$1}'))
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mrtg2pcp localhost ${disk_list[0]} UTF-8 /var/www/mrtg/mrtg-m.png mrtgpcp
    CHECK_RESULT $?
    grep -aE "localhost|UTF-8" mrtgpcp.index
    CHECK_RESULT $?
    test -f mrtgpcp.0 -a -f mrtgpcp.meta && rm -rf mrtgpcp.0 mrtgpcp.meta mrtgpcp.index
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
