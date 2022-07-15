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
    version=$(rpm -qa wireshark | awk -F "-" '{print$2}')
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    dumpcap --help | grep "Usage: dumpcap \[options\]"
    CHECK_RESULT $?
    dumpcap --version | grep "$version"
    CHECK_RESULT $?
    dumpcap -D | grep "[0-9]"
    CHECK_RESULT $?
    netCard=$(dumpcap -D | awk -F '.' '{print $2}' | head -1)
    SLEEP_WAIT 10 "dumpcap -i $netCard -c 20 -w testfile1" 2
    grep -a $netCard testfile1
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard -f \"tcp port 22\" -c 20 -w testfile2" 2
    grep -a "tcp port 22" testfile2
    CHECK_RESULT $?
    capinfos testfile2 | grep "Filter string = tcp port 22"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard -s 1 -c 20 -w testfile3" 2
    capinfos testfile3 | grep " Capture length = 1"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard -p -c 20 -w testfile4" 2
    capinfos testfile4 | grep "Number of packets:.*20"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard -L | grep \"Data link types of interface\"" 2
    linkType=$(dumpcap -i $netCard -L | sed -n '2p' | awk '{print $1}')
    SLEEP_WAIT 5 "dumpcap -i $netCard -y $linkType -c 20 -w testfile5" 2
    capinfos testfile5 | grep -E "$netCard|Ethernet"
    CHECK_RESULT $?
    expect <<EOF
        log_file log1
        spawn dumpcap -S
        sleep 5
        expect "" {send "\03"}
        expect eof
EOF
    grep -E "Interface|Received|Dropped|[0-9]" log1
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -M -D | grep -E \"[0-9]|network\"" 2
    SLEEP_WAIT 5 "dumpcap -M -L | grep -E \"Ethernet|DOCSIS\"" 2
    expect <<EOF
        log_file log2
        spawn dumpcap -M -S
        sleep 5
        expect "" {send "\03"}
        expect eof
EOF
    grep "[0-9]" log2
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
