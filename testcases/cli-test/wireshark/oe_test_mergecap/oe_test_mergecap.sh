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
# @Date      :   2020/10/22
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of mergecap command
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
    mergecap --help | grep "Usage: mergecap \[options\]"
    CHECK_RESULT $?
    mergecap --version | grep "$version"
    CHECK_RESULT $?
    netCard=$(dumpcap -D | awk -F '.' '{print $2}' | head -1)
    SLEEP_WAIT 10 "dumpcap -i $netCard -c 20 -w testfile1" 2
    capinfos testfile1 | grep "Number of packets:.*20"
    CHECK_RESULT $?
    SLEEP_WAIT 5 "dumpcap -i $netCard -f \"tcp port 22\" -c 20 -w testfile2" 2
    capinfos testfile2 | grep -E "Number of packets:.*20|Filter string = tcp port 22"
    CHECK_RESULT $?
    mergecap -a -w mergefile1 testfile1 testfile2
    CHECK_RESULT $?
    capinfos mergefile1 | grep "Number of packets:.*40"
    CHECK_RESULT $?
    mergecap -a -s 10 -w mergefile2 testfile1 testfile2
    CHECK_RESULT $?
    capinfos mergefile2 | grep -E "Number of packets:.*40|Packet size limit:.*inferred: 10 bytes"
    CHECK_RESULT $?
    mergecap -a -w mergefile3 testfile1 testfile2
    CHECK_RESULT $?
    capinfos mergefile3 | grep "File name:.*mergefile3"
    CHECK_RESULT $?
    captype testfile1 | grep "testfile1: pcapng"
    CHECK_RESULT $?
    captype testfile2 | grep "testfile2: pcapng"
    CHECK_RESULT $?
    mergecap -a -F snoop -w mergefile4 testfile1 testfile2
    CHECK_RESULT $?
    captype mergefile4 | grep "mergefile4: snoop"
    CHECK_RESULT $?
    mergecap -a -I none -w mergefile5 testfile1 testfile2
    CHECK_RESULT $?
    capinfos mergefile5 | grep -E "Number of packets = 20|Filter string = tcp port 22|Interface #.* info:"
    CHECK_RESULT $?
    mergecap -a -v -w mergefile6 testfile1 testfile2 >runlog 2>&1
    CHECK_RESULT $?
    grep -E "mergecap|Record|merging complete|ready to merge records" runlog
    CHECK_RESULT $?
    capinfos mergefile6 | grep "Number of packets:.*40"
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
