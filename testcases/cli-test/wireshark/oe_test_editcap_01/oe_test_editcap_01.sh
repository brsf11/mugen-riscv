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
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/22
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of editcap command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL wireshark
    version=$(rpm -qa wireshark | awk -F "-" '{print$2}')
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    editcap --help | grep "Usage: editcap \[options\]"
    CHECK_RESULT $?
    editcap --version | grep "$version"
    CHECK_RESULT $?
    netCard=$(dumpcap -D | awk -F '.' '{print $2}' | head -1)
    SLEEP_WAIT 10 "dumpcap -i $netCard -c 20 -w testfile1" 2
    capinfos testfile1 | grep "Number of packets:.*20"
    CHECK_RESULT $?
    editcap -r testfile1 testfile1_A 2-5
    CHECK_RESULT $?
    capinfos testfile1_A | grep "Number of packets:.*4"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard -f \"tcp port 22\" -c 20 -w testfile2" 2
    grep -a "tcp port 22" testfile2
    CHECK_RESULT $?
    capinfos testfile2 | grep -E "Number of packets:.*20|Filter string = tcp port 22"
    CHECK_RESULT $?
    SLEEP_WAIT 3
    editcap -A "$(date '+%Y-%m-%d %T')" testfile2 testfile2_A
    CHECK_RESULT $?
    capinfos testfile2_A | grep "Number of packets:.*0"
    CHECK_RESULT $?
    editcap -B "$(date '+%Y-%m-%d %T')" testfile2 testfile2_B
    CHECK_RESULT $?
    capinfos testfile2_B | grep "Number of packets:.*20"
    CHECK_RESULT $?
    editcap -d testfile2 testfile2_C
    CHECK_RESULT $?
    capinfos testfile2_C | grep "File size:.*bytes"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard -c 20 -w testfile3" 2
    capinfos testfile3 | grep "Number of packets:.*20"
    CHECK_RESULT $?
    editcap -D 10 testfile3 testfile3_A
    CHECK_RESULT $?
    capinfos testfile3_A | grep -E "File size:.*bytes|Number of stat entries = 0"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard -p -c 20 -w testfile4" 2
    capinfos testfile4 | grep "Number of packets:.*20"
    CHECK_RESULT $?
    editcap -w 0.01 testfile4 testfile4_A
    CHECK_RESULT $?
    capinfos testfile4_A | grep "File size:.*bytes"
    CHECK_RESULT $?
    linkType=$(dumpcap -i $netCard -L | sed -n '2p' | awk '{print $1}')
    SLEEP_WAIT 5 "dumpcap -i $netCard -y $linkType -c 20 -w testfile5" 2
    capinfos testfile5 | grep -E "$netCard|Ethernet"
    CHECK_RESULT $?
    editcap -s 10 testfile5 testfile5_A
    CHECK_RESULT $?
    capinfos testfile5_A | grep "Packet size limit:.*inferred:.*10.*bytes"
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
