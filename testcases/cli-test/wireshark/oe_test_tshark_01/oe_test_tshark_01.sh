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
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of tshark command
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
    tshark --help | grep "Usage: tshark \[options\]"
    CHECK_RESULT $?
    tshark --version | grep "$version"
    CHECK_RESULT $?
    netCard=$(tshark -D | awk -F '.' '{print $2}' | head -1)
    SLEEP_WAIT 5 "tshark -i $netCard -c 10 -w tsfile1" 2
    capinfos tsfile1 | grep -E $netCard"|Number of packets:.*10|File name:.*tsfile1"
    CHECK_RESULT $?
    expect <<EOF
            spawn tshark -i $netCard -f "tcp dst port 22" -c 15 -w tsfile2
            sleep 1
            expect eof
EOF
    grep -a "tcp dst port 22" tsfile2
    CHECK_RESULT $?
    capinfos tsfile2 | grep -E "File name:.*tsfile2|Number of packets:.*15|Filter string = tcp dst port 22"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "tshark -i $netCard -s 100 -c 10 -w tsfile3" 2
    capinfos tsfile3 | grep -E "Packet size limit:.*inferred: 100 bytes|Number of packets:.*10|File name:.*tsfile3"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "tshark -i $netCard -p -c 10 -w tsfile4" 2
    capinfos tsfile4 | grep -E "Number of packets:.*10|File name:.*tsfile4"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "tshark -i $netCard -B 5 -c 10 -w tsfile5" 2
    capinfos tsfile5 | grep -E "Number of packets:.*10|File name:.*tsfile5"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "tshark -i $netCard -L | grep \"Data link types of interface\"" 2
    linkType=$(tshark -i $netCard -L | sed -n '2p' | awk '{print $1}')
    SLEEP_WAIT 5 "tshark -i $netCard -y $linkType -c 10 -w tsfile6" 2
    capinfos tsfile6 | grep -E "File encapsulation:.*Ethernet|File name:.*tsfile6"
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
