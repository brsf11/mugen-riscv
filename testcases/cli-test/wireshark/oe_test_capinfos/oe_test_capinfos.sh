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
# @Desc      :   verify the uasge of capinfos command
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
    capinfos --help | grep "Usage: capinfos \[options\] <infile>"
    CHECK_RESULT $?
    capinfos --version | grep "$version"
    CHECK_RESULT $?
    netCard=$(dumpcap -D | awk -F '.' '{print $2}' | head -1)
    SLEEP_WAIT 10 "dumpcap -i $netCard -c 20 -w testfile1" 2
    test -f testfile1
    CHECK_RESULT $?
    capinfos -t testfile1 | grep -E "File type|Wireshark/... - pcapng"
    CHECK_RESULT $?
    capinfos -E testfile1 | grep -E "File encapsulation|Ethernet"
    CHECK_RESULT $?
    capinfos -I testfile1 | grep "Interface #0 info:"
    CHECK_RESULT $?
    capinfos -F testfile1 | grep -Ei "file|Capture"
    CHECK_RESULT $?
    SLEEP_WAIT 10 "dumpcap -i $netCard --capture-comment \"test dumpcap usage\" -c 20 -w testfile17" 2
    test -f testfile17
    CHECK_RESULT $?
    capinfos -k testfile17 | grep "Capture comment:.*test dumpcap usage"
    CHECK_RESULT $?
    capinfos -c testfile1 | grep -E "Number of packets|20"
    CHECK_RESULT $?
    capinfos -s testfile1 | grep "File size"
    CHECK_RESULT $?
    capinfos -u testfile1 | grep "Capture duration:"
    CHECK_RESULT $?
    capinfos -a testfile1 | grep "First packet time: "
    CHECK_RESULT $?
    capinfos -e testfile1 | grep "Last packet time:"
    CHECK_RESULT $?
    capinfos -y testfile1 | grep "Data byte rate:"
    CHECK_RESULT $?
    capinfos -z testfile1 | grep "Average packet size:"
    CHECK_RESULT $?
    capinfos -x testfile1 | grep "Average packet rate:"
    CHECK_RESULT $?
    capinfos -L testfile1 | grep -E "File|packet|size|Capture|time|rate|Interface"
    CHECK_RESULT $?
    capinfos -T testfile1 | grep ".*"
    CHECK_RESULT $?
    capinfos -T -R testfile1 | grep "File"
    CHECK_RESULT $?
    capinfos -T -r testfile1 | grep "File"
    CHECK_RESULT $? 1
    capinfos -T -B testfile1 | grep $'\t'
    CHECK_RESULT $?
    capinfos -T -m testfile1 | grep ","
    CHECK_RESULT $?
    capinfos -T -b testfile1 | grep "[[:space:]]"
    CHECK_RESULT $?
    capinfos -A testfile1 | grep -E "File|packet|size|Capture|time|rate|Interface"
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
