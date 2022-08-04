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
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    netCard=$(tshark -D | awk -F '.' '{print $2}' | head -1)
    SLEEP_WAIT 5 "tshark -i $netCard -a duration:5 -w tsfile7" 2
    capinfos tsfile7 | grep -E "Capture duration:.*seconds|File name:.*tsfile7"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "tshark -i $netCard -a filesize:3 -w tsfile8" 2
    capinfos tsfile8 | grep -E "File size:.*bytes|File name:.*tsfile8"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "tshark -i $netCard -a files:3 -a filesize:2 -w tsfile9" 2
    CHECK_RESULT "$(ls | grep -c 'tsfile9_')" 3
    capinfos tsfile9_* | grep -E "File size:.*bytes|File name:.*tsfile9_.*"
    CHECK_RESULT $?
    expect <<EOF
        spawn tshark -i $netCard -b duration:6 -w tsfile10
        expect eof
EOF
    capinfos tsfile10_* | grep -E "Capture duration:.*seconds|File name:.*tsfile10_.*"
    CHECK_RESULT $?
    expect <<EOF
        spawn tshark -i $netCard -b interval:1 -w tsfile11
        expect eof
EOF
    capinfos tsfile11_* | grep -E "Capture duration:.*seconds|File name:.*tsfile11_.*"
    CHECK_RESULT $?
    expect <<EOF
        spawn tshark -i $netCard -b filesize:2 -w tsfile12
        expect eof
EOF
    capinfos tsfile12_* | grep -E "File size:.*bytes|File name:.*tsfile12_.*"
    CHECK_RESULT $?
    expect <<EOF
        spawn tshark -i $netCard -b files:2 -b filesize:1 -w tsfile13
        sleep 5
        expect eof
EOF
    capinfos tsfile13_* | grep -E "File size:.*bytes|File name:.*tsfile13_.*"
    CHECK_RESULT $?
    CHECK_RESULT "$(ls | grep -c 'tsfile13_')" 2
    SLEEP_WAIT 5 "tshark -i 1 -c 50 -w anyFile" 2
    capinfos anyFile | grep -E "Number of packets:.*50|File name:.*anyFile"
    CHECK_RESULT $?
    tshark -r anyFile | grep -E "SSH|TCP|STP"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "tshark -r anyFile -R \"tcp.dstport==22\" -2 -w tcpFile1" 2
    capinfos tcpFile1 | grep "File name:.*tcpFile1"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "tshark -r tcpFile1 | grep \"TCP\"" 2
    SLEEP_WAIT 5 "tshark -i $netCard -n -c 20 -w tsfile14" 2
    capinfos tsfile14 | grep -E "File name:.*tsfile14|Number of packets:.*20"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "tshark -i $netCard -N m -c 20 -w tsfile15" 2
    capinfos tsfile15 | grep -E "File name:.*tsfile15|Number of packets:.*20"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "tshark -i $netCard -d \"tcp.port==8888,http\" -c 20 -w tsfile16" 2
    capinfos tsfile16 | grep "File name:.*tsfile16"
    CHECK_RESULT $?
    captype tsfile16 | grep "tsfile16: pcapng"
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
