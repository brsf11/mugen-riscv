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
    netCard=$(tshark -D | awk -F '.' '{print $2}' | head -1)
    SLEEP_WAIT 5 "tshark -i 1 -F pcap -c 10 -w tsfile17" 2
    capinfos tsfile17 | grep -E "File type:.*pcap|File name:.*tsfile17"
    CHECK_RESULT $?
    captype tsfile17 | grep "tsfile17: pcap"
    CHECK_RESULT $?
    tshark -i $netCard -c 100 -V | grep -E "Linux cooked capture|SSH Protocol|Internet Protocol Version"
    CHECK_RESULT $?
    tshark -i $netCard -c 10 -x | grep "0*"
    CHECK_RESULT $?
    tshark -i $netCard -c 5 -T json | grep -E "{|}"
    CHECK_RESULT $?
    curTime=$(date +%Y-%m-%d)
    SLEEP_WAIT 5 "tshark -i $netCard -c 10 -t ad | grep $curTime" 2
    tshark -i $netCard -c 10 -x -S\ "-------" | grep -E "0*|\-------"
    CHECK_RESULT $?
    tshark -i $netCard -l -c 10 | grep "[0-9]"
    CHECK_RESULT $?
    tshark -i $netCard -c 10 -X tcp:22 | grep -E "[0-9]|TCP"
    CHECK_RESULT $?
    tshark -i $netCard -c 10 -q -z http,tree | grep "HTTP/Packet Counter:"
    CHECK_RESULT $?
    tshark -i $netCard -c 10 -n -q -z http,stat, -z http,tree | grep -E "HTTP/Packet Counter:|HTTP Statistics"
    CHECK_RESULT $?
    rawshark --help | grep "Usage: rawshark \[options\]"
    CHECK_RESULT $?
    rawshark --version | grep "$version"
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
