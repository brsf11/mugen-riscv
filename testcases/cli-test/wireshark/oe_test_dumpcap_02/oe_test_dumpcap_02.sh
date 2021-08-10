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

source "../common/common_wireshark.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    netCard=$(dumpcap -D | awk -F '.' '{print $2}' | head -1)
    dumpcap -i $netCard -c 2 -w testfile6
    CHECK_RESULT $?
    capinfos testfile6 | grep "Number of packets:.*2"
    CHECK_RESULT $?
    dumpcap -i 1 -a duration:5 -w testfile7
    CHECK_RESULT $?
    capinfos testfile7 | grep "Capture duration:.*"
    CHECK_RESULT $?
    dumpcap -i 3 -a filesize:1 -w testfile8
    CHECK_RESULT $?
    capinfos testfile8 | grep "File size:.*"
    CHECK_RESULT $?
    dumpcap -i $netCard -a files:2 -a filesize:1 -w testfile9
    CHECK_RESULT $?
    CHECK_RESULT "$(ls | grep -c 'testfile9_.*')" "2"
    dumpcap -i $netCard -a filesize:1 -w testfile10
    CHECK_RESULT $?
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
    dumpcap -i $netCard -n -c 20 -w testfile15
    CHECK_RESULT $?
    captype testfile15 | grep "testfile15: pcapng"
    CHECK_RESULT $?
    dumpcap -i $netCard -P -c 20 -w testfile16
    CHECK_RESULT $?
    captype testfile16 | grep "testfile16: pcap"
    CHECK_RESULT $?
    dumpcap -i $netCard --capture-comment "test dumpcap usage" -c 20 -w testfile17
    CHECK_RESULT $?
    capinfos testfile17 | grep "Capture comment:.*test dumpcap usage"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
