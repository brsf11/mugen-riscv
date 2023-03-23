#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   dingjiao
#@Contact   	:   15829797643@163.com
#@Date      	:   2022-07-06
#@License   	:   Mulan PSL v2
#@Desc      	:   Generate and check digest files and TLV files
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    mkdir -p /tmp/test/test1
    touch /tmp/test/doc.txt
    DNF_INSTALL digest-list-tools
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    gen_digest_lists -t metadata -f compact -i l: -o add -p -1 -m immutable -i I:/tmp/test -d /tmp/ -i i: -i x:
    CHECK_RESULT $? 0 0 "Set digest file: failed!"
    test -f /tmp/0-metadata_list-compact-test
    CHECK_RESULT $? 0 0 "Check digest file: failed!"
    gen_digest_lists -t metadata -f compact -i l: -o add -p -1 -m immutable -i I:/tmp/test -d /tmp/ -i i: -T
    CHECK_RESULT $? 0 0 "Set tlv file: failed!"
    test -f /tmp/0-metadata_list-compact_tlv-test
    CHECK_RESULT $? 0 0 "Check tlv file: failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/test /tmp/0-metadata_list-compact-test /tmp/0-metadata_list-compact_tlv-test
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
