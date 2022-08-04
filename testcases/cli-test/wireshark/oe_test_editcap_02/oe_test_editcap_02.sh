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
    DNF_INSTALL "wireshark bc"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    netCard=$(dumpcap -D | awk -F '.' '{print $2}' | head -1)
    SLEEP_WAIT 10 "dumpcap -i $netCard -c 20 -w testfile6" 2
    capinfos testfile6 | grep "Number of packets:.*2"
    CHECK_RESULT $?
    editcap -C 20 testfile6 testfile6_A
    CHECK_RESULT $?
    capinfos testfile6_A | grep "Packet size limit:.*inferred:.*bytes - .*bytes (range)"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i 1 -a duration:5 -w testfile7" 2
    capinfos testfile7 | grep "Capture duration:.*"
    CHECK_RESULT $?
    editcap -t -0.5 testfile7 testfile7_A
    CHECK_RESULT $?
    s1=$(capinfos testfile7 | grep "[0-9]:[0-9]" | awk -F ':' '{print $NF}' | head -1)
    e1=$(capinfos testfile7 | grep "[0-9]:[0-9]" | awk -F ':' '{print $NF}' | tail -1)
    s2=$(echo $s1-0.5 | bc)
    e2=$(echo $e1-0.5 | bc)
    capinfos testfile7_A | grep -E $s2"|"$e2
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i 1 -a filesize:1 -w testfile8" 2
    capinfos testfile8 | grep "File size:.*bytes"
    CHECK_RESULT $?
    editcap -E 0.05 testfile8 testfile8_A
    CHECK_RESULT $?
    capinfos testfile8_A | grep "File size:.*bytes"
    CHECK_RESULT $?
    editcap -c 2 testfile8 testfile8_B
    CHECK_RESULT $?
    capinfos testfile8_B* | grep "Number of packets:.*"
    CHECK_RESULT $?
    editcap -i 1 testfile7 testfile7_B
    CHECK_RESULT $?
    capinfos testfile7_B_* | grep -E "Capture duration|11:43"
    CHECK_RESULT $?
    SLEEP_WAIT 10 "dumpcap -i $netCard -f \"tcp port 22\" -c 20 -w testfile2" 2
    captype testfile2 | grep "testfile2: pcapng"
    CHECK_RESULT $?
    editcap -F pcap testfile2 testfile2_D
    CHECK_RESULT $?
    captype testfile2_D | grep "testfile2_D: pcap"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard -c 20 -w testfile1" 2
    capinfos -E testfile1 | grep "File encapsulation:.*Ethernet"
    CHECK_RESULT $?
    editcap -T ap1394 testfile1 testfile1_B
    CHECK_RESULT $?
    capinfos -E testfile1_B | grep "File encapsulation:.*Apple IP-over-IEEE 1394"
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
