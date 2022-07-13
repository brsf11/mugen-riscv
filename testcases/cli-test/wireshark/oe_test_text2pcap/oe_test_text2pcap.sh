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
# @Desc      :   verify the uasge of text2pcap command
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
    text2pcap --help | grep "Usage: text2pcap \[options\] <infile> <outfile>"
    CHECK_RESULT $?
    text2pcap --version | grep "$version"
    CHECK_RESULT $?
    text2pcap -o hex test.txt test.pcap
    CHECK_RESULT $?
    grep -a "Hello World!" test.pcap
    CHECK_RESULT $?
    capinfos test.pcap | grep "File name:.*test.pcap"
    CHECK_RESULT $?
    text2pcap -t "%H:%M:%S" test.txt test1.pcap
    CHECK_RESULT $?
    capinfos test1.pcap | grep -E "File name:.*test.pcap|$(date +%Y-%m-%d)"
    CHECK_RESULT $?
    text2pcap -l 7 test.txt test2.pcap
    CHECK_RESULT $?
    capinfos test2.pcap | grep -E "File name:.*test2.pcap|File encapsulation:.*ARCNET"
    CHECK_RESULT $?
    text2pcap -m 20 test.txt test3.pcap
    CHECK_RESULT $?
    capinfos test3.pcap | grep "Packet size limit:.*file hdr:.*bytes"
    CHECK_RESULT $?
    text2pcap -e 0x806 -m 100 test.txt test4.pcap >runlog 2>&1
    CHECK_RESULT $?
    grep "Generate dummy Ethernet header: Protocol: 0x806" runlog
    CHECK_RESULT $?
    capinfos test4.pcap | grep -E "File name:.*test4.pcap|File encapsulation:.*Ethernet"
    CHECK_RESULT $?
    text2pcap -i 1 test.txt test5.pcap >runlog 2>&1
    CHECK_RESULT $?
    grep -E "Generate dummy Ethernet header: Protocol: 0x800|Generate dummy IP header: Protocol:.*" runlog
    CHECK_RESULT $?
    capinfos test5.pcap | grep -E "File name:.*test5.pcap|Encapsulation = Ethernet.*(1 - ether)"
    CHECK_RESULT $?
    text2pcap -u 1000,69 test.txt test6.pcap >runlog 2>&1
    CHECK_RESULT $?
    grep -E "Generate dummy Ethernet header: Protocol: 0x800|Generate dummy IP header: Protocol:.*|Generate dummy UDP header: Source port: 1000. Dest port: 69" runlog
    CHECK_RESULT $?
    capinfos test6.pcap | grep "File name:.*test6.pcap"
    CHECK_RESULT $?
    text2pcap -T 50,60 test.txt test7.pcap >runlog 2>&1
    CHECK_RESULT $?
    grep -E "Generate dummy Ethernet header: Protocol: 0x800|Generate dummy IP header: Protocol:.*|Generate dummy TCP header: Source port: 50. Dest port: 60" runlog
    CHECK_RESULT $?
    capinfos test7.pcap | grep "File name:.*test7.pcap"
    CHECK_RESULT $?
    text2pcap -s 30,40,34 test.txt test8.pcap >runlog 2>&1
    CHECK_RESULT $?
    grep -E "Generate dummy Ethernet header: Protocol: 0x800|Generate dummy IP header: Protocol:.*|Generate dummy SCTP header: Source port: 30. Dest port: 40. Tag: 34" runlog
    CHECK_RESULT $?
    capinfos test8.pcap | grep "File name:.*test8.pcap"
    CHECK_RESULT $?
    text2pcap -S 30,40,34 test.txt test9.pcap >runlog 2>&1
    CHECK_RESULT $?
    grep -E "Generate dummy SCTP header: Source port: 30. Dest port: 40. Tag: 0|Generate dummy DATA chunk header: TSN: 0. SID: 0. SSN: 0. PPID: 34" runlog
    CHECK_RESULT $?
    capinfos test9.pcap | grep "File name:.*test9.pcap"
    CHECK_RESULT $?
    text2pcap -d test.txt test10.pcap >runlog 2>&1
    CHECK_RESULT $?
    grep -E "Start new packet|parse_preamble" runlog
    CHECK_RESULT $?
    capinfos test10.pcap | grep "File name:.*test10.pcap"
    CHECK_RESULT $?
    text2pcap -q test.txt test11.pcap
    CHECK_RESULT $?
    capinfos test11.pcap | grep "File name:.*test11.pcap"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -vE ".sh|.txt")
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
