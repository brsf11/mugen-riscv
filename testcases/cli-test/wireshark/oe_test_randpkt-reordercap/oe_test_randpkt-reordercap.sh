#!/bin/bash
# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/22
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of randpkt and reordercap command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL wireshark
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    randpkt --help | grep "Usage: randpkt"
    CHECK_RESULT $?
    randpkt -b 100 -c 100 -t ipv6 randomfile1
    CHECK_RESULT $?
    capinfos randomfile1 | grep -E "Packet size limit:.*file hdr: 100 bytes|Number of packets:.*100|File encapsulation:.*Ethernet"
    CHECK_RESULT $?
    randpkt -b 100 -c 100 -r randomfile2
    CHECK_RESULT $?
    capinfos randomfile2 | grep -E "Packet size limit:.*file hdr: 100 bytes|Number of packets:.*100|File encapsulation:.*"
    CHECK_RESULT $?
    reordercap --help | grep "Usage: reordercap \[options\] <infile> <outfile>"
    CHECK_RESULT $?
    reordercap -n randomfile1 randomfile1_A
    CHECK_RESULT $?
    capinfos randomfile1_A | grep "File name:.*randomfile1_A"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -v ".sh")
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
