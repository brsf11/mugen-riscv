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
        log_file target_log6
        spawn targetcli
        expect "/>" {send "ls\r"}
        expect "/>" {send "cd iscsi\r"}
        expect "/iscsi> " {send "ls\r"}
        expect "/iscsi> " {send "cd ..\r"}
        expect "/>" {send "ls\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    grep -E "\/iscsi>|backstores|iscsi|loopback|vhost|xen-pvscsi|block|fileio|pscsi|ramdisk" target_log6
    CHECK_RESULT $?
    expect <<EOF
        log_file target_log7
        spawn targetcli
        expect "/>" {send "help bookmarks\r"}
        expect "/>" {send "iscsi/ create\r"}
        expect "/>" {send "cd iscsi\r"}
        expect "/iscsi> " {send "bookmarks add iscsi\r"}
        expect "/iscsi> " {send "bookmarks show\r"}
        expect "/iscsi> " {send "bookmarks go last\r"}
        expect "/tpg1> " {send "pwd\r"}
        expect "/tpg1> " {send "bookmarks del iscsi\r"}
        expect "/tpg1> " {send "bookmarks del last\r"}
        expect "/tpg1> " {send "bookmarks show\r"}
        expect "/tpg1> " {send "cd /\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    grep -E "bookmarks action \[bookmark\]|Manage your bookmarks|Created target iqn.2003-01|last|\/iscsi/iqn.2003-01.org.linux|Bookmarked \/iscsi as iscsi|Deleted bookmark iscsi|Deleted bookmark last|No bookmarks yet" target_log7
    CHECK_RESULT $?
    iscsiName=$(targetcli ls | grep iqn.2003-01 | awk -F " " '{print $3}')
    expect <<EOF
        spawn targetcli
        expect "/>" {send "iscsi/ delete $iscsiName\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    expect <<EOF
        log_file target_log8
        spawn targetcli
        expect "/>" {send "help get\r"}
        expect "/>" {send "get global\r"}
        expect "/>" {send "get global color_mode loglevel_console\r"}
        expect "/>" {send "help refresh\r"}
        expect "/>" {send "refresh\r"}
        expect "/>" {send "help status\r"}
        expect "/>" {send "status\r"}
        expect "/>" {send "help version\r"}
        expect "/>" {send "version\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    grep -E "get \[group\] \[parameter...\]|GLOBAL CONFIG GROUP|\-----|\=|Gets the value of one or more configuration parameters in the given group|Refreshes and updates the objects tree from the current path|Displays the current node's status summary|Displays the targetcli and support libraries versions|Status for \/\:|targetcli version|color_mode=true|loglevel_console=info" target_log8
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -v ".sh")
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
