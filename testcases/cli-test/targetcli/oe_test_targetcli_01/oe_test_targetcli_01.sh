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
# @Date      :   2020/10/09
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of targetcli command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL targetcli
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
        log_file target_log1
        spawn targetcli
        expect "/>" {send "ls\r"}
        expect "/>" {send "help\r"}
        expect "/>" {send "backstores/fileio create file1 /tmp/disk1.img 100M\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    grep -E "\-|Created fileio file1 with size" target_log1
    CHECK_RESULT $?
    targetcli ls | grep "file1"
    CHECK_RESULT $?
    expect <<EOF
        log_file target_log2
        spawn targetcli
        expect "/>" {send "ls\r"}
        expect "/>" {send "iscsi/ create\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    grep -E "Created target iqn.2003-01*|portals|3260" target_log2
    CHECK_RESULT $?
    targetcli ls | grep -E "iqn.2003-01|portals|3260"
    CHECK_RESULT $?
    iscsiName=$(targetcli ls | grep iqn.2003-01 | awk -F " " '{print $3}')
    expect <<EOF
        log_file target_log3
        spawn targetcli
        expect "/>" {send "ls\r"}
        expect "/>" {send "iscsi/$iscsiName/tpg1/luns/ create /backstores/fileio/file1\r"} 
        expect "/>" {send "exit\r"}
        expect eof
EOF
    grep "Created LUN 0" target_log3
    CHECK_RESULT $?
    targetcli ls | grep "lun0"
    CHECK_RESULT $?
    expect <<EOF
        log_file target_log4
        spawn targetcli
        expect "/>" {send "ls\r"}
        expect "/>" {send "iscsi/ delete $iscsiName\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    grep "Deleted Target iqn.2003-01" target_log4
    CHECK_RESULT $?
    targetcli ls | grep "iqn.2003-01"
    CHECK_RESULT $? 1
    expect <<EOF
        log_file target_log5
        spawn targetcli
        expect "/>" {send "ls\r"}
        expect "/>" {send "backstores/fileio delete file1\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    grep "Deleted storage object file1" target_log5
    CHECK_RESULT $?
    targetcli ls | grep "file1"
    CHECK_RESULT $? 1
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -v ".sh")
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
