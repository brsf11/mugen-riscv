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
# @Desc      :   verify the uasge of dumpcap command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL wireshark
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    netCard=$(dumpcap -D | awk -F '.' '{print $2}' | head -1)
    SLEEP_WAIT 10 "dumpcap -i $netCard -c 2 -w testfile6" 2
    capinfos testfile6 | grep "Number of packets:.*2"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i 1 -a duration:5 -w testfile7" 2
    capinfos testfile7 | grep "Capture duration:.*"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i 1 -a filesize:1 -w testfile8" 2
    capinfos testfile8 | grep "File size:.*"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard -a files:2 -a filesize:1 -w testfile9" 2
    CHECK_RESULT "$(ls | grep -c 'testfile9_.*')" 2
    SLEEP_WAIT 5 "dumpcap -i $netCard -a filesize:1 -w testfile10" 2
    capinfos testfile10 | grep "File name:.*testfile10"
    CHECK_RESULT $?
    expect <<EOF
        spawn dumpcap -i 1 -b duration:1 -w testfile11 
        sleep 5
        expect "" {send "\03"}
        expect eof
EOF
    ls | grep "testfile11_.*"
    CHECK_RESULT $?
    expect <<EOF
        spawn dumpcap -i 3 -b interval:1 -w testfile12 
        sleep 5
        expect "" {send "\03"}
        expect eof
EOF
    ls | grep "testfile12_.*"
    CHECK_RESULT $?
    expect <<EOF
        spawn dumpcap -i $netCard -b filesize:2 -w testfile13
        sleep 20
        expect "" {send "\03"}
        expect eof
EOF
    ls | grep "testfile13_.*"
    CHECK_RESULT $?
    expect <<EOF
        spawn dumpcap -i $netCard -b files:2 -a filesize:1 -w testfile14
        sleep 20
        expect "" {send "\03"}
        expect eof
EOF
    ls | grep "testfile14_.*"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard -n -c 20 -w testfile15" 2
    captype testfile15 | grep "testfile15: pcapng"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard -P -c 20 -w testfile16" 2
    captype testfile16 | grep "testfile16: pcap"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard --capture-comment \"test dumpcap usage\" -c 20 -w testfile17" 2
    capinfos testfile17 | grep "Capture comment:.*test dumpcap usage"
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
