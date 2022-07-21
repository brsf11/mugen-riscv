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
    version=$(cat /etc/os-release | grep VERSION= | cut -c 10-14)
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    targetcli iscsi/ create | grep "Created target iqn.2003-01"
    CHECK_RESULT $?
    targetcli help 2>&1 | grep "\-"
    CHECK_RESULT $?
    if [ $version == '22.03' ]
    then
        targetcli help  2>&1 | grep -E "Usage|\-"
        CHECK_RESULT $?
    elif [ $version == '20.03']
    then
        targetcli help bookmarks | grep -E "bookmarks action \[bookmark\]|Manage your bookmarks|\-"
        CHECK_RESULT $?
        targetcli help cd | grep -E "cd \[path\]|Change current path to path|\-"
        CHECK_RESULT $?
        targetcli help exit | grep -E "exit|Exits the command line interface"
        CHECK_RESULT $?
        targetcli help ls | grep -E "ls \[path\] \[depth\]|Display either the nodes tree relative to path or to the current node"
        CHECK_RESULT $?
        targetcli help refresh | grep -E "refresh|Refreshes and updates the objects tree from the current path"
        CHECK_RESULT $?
        targetcli help status | grep -E "status|Displays the current node's status summary"
        CHECK_RESULT $?
        targetcli help version | grep -E "version|Displays the targetcli and support libraries versions"
        CHECK_RESULT $?
        targetcli help sessions | grep -E "sessions \[action\] \[sid\]|Displays a detailed list of all open sessions|\-"
        CHECK_RESULT $?
        targetcli help get | grep -E "get \[group\] \[parameter...\]|Gets the value of one or more configuration parameters in the given|Example"
        CHECK_RESULT $?
        targetcli help set | grep -E "set \[group\] \[parameter=value...\]|Sets one or more configuration parameters in the given group|Example:"
        CHECK_RESULT $?
        targetcli help saveconfig | grep -E "saveconfig \[savefile\]|Saves the current configuration to a file"
        CHECK_RESULT $?
        targetcli help clearconfig | grep -E "clearconfig \[confirm\]|Removes entire configuration of backstores and targets"
        CHECK_RESULT $?
        targetcli help restoreconfig | grep -E "restoreconfig \[savefile\] \[clear_existing\]|Restores configuration from a file"
        CHECK_RESULT $?
    fi
    targetcli bookmarks show | grep -E "last|/iscsi/iqn.2003-01.org.linux-iscsi.localhost.aarch64"
    CHECK_RESULT $?
    targetcli bookmarks add root | grep "Bookmarked / as root."
    CHECK_RESULT $?
    targetcli bookmarks show | grep -E "last|/iscsi/iqn.2003-01.org.linux-iscsi.localhost.aarch64|root|\/"
    CHECK_RESULT $?
    targetcli bookmarks go last
    CHECK_RESULT $?
    expect <<EOF
        log_file target_log13
        spawn targetcli
        expect "/tpg1> " {send "pwd\r"}
        expect "/tpg1> " {send "exit\r"}
        expect eof
EOF
    grep "/iscsi/iqn.2003-01.org.linux-iscsi*" target_log13
    CHECK_RESULT $?
    targetcli bookmarks go root
    CHECK_RESULT $?
    targetcli bookmarks del root | grep -E "Deleted bookmark root"
    CHECK_RESULT $?
    targetcli bookmarks show | grep "root|\/"
    CHECK_RESULT $? 1
    targetcli cd backstores/
    CHECK_RESULT $?
    expect <<EOF
        log_file target_log14
        spawn targetcli
        expect "> " {send "pwd\r"}
        expect "> " {send "exit\r"}
        expect eof
EOF
    grep "\/backstores" target_log14
    CHECK_RESULT $?
    targetcli cd ..
    CHECK_RESULT $?
    targetcli ls | grep -E "backstores|iscsi|loopback|vhost|xen-pvscsi|block|fileio|pscsi|ramdisk"
    CHECK_RESULT $?
    targetcli refresh
    CHECK_RESULT $?
    targetcli status | grep "Status for /:"
    CHECK_RESULT $?
    targetcli version 2>&1 | grep "targetcli version"
    CHECK_RESULT $?
    targetcli sessions | grep "no open sessions"
    CHECK_RESULT $?
    targetcli get global color_mode loglevel_console | grep -E "color_mode=|loglevel_console="
    CHECK_RESULT $?
    targetcli set global auto_save_on_exit=false | grep -E "Parameter auto_save_on_exit is now 'false'"
    CHECK_RESULT $?
    targetcli get global auto_save_on_exit | grep "auto_save_on_exit=false"
    CHECK_RESULT $?
    targetcli set global auto_save_on_exit=true | grep -E "Parameter auto_save_on_exit is now 'true'"
    CHECK_RESULT $?
    targetcli backstores/fileio create file1 /tmp/disk1.img 100M | grep "Created fileio file1"
    CHECK_RESULT $?
    iscsiName=$(targetcli ls | grep iqn.2003-01 | awk -F " " 'NR==1{print $3}')
    targetcli iscsi/$iscsiName/tpg1/luns/ create /backstores/fileio/file1 | grep "Created LUN 0"
    CHECK_RESULT $?
    targetcli ls | grep -E "file1|$iscsiName|lun0"
    CHECK_RESULT $?
    targetcli saveconfig | grep "Configuration saved to /etc/target/saveconfig.json"
    CHECK_RESULT $?
    grep -E "file1|$iscsiName" /etc/target/saveconfig.json
    CHECK_RESULT $?
    targetcli clearconfig confirm=True | grep "All configuration cleared"
    targetcli ls | grep -E "file1|$iscsiName|lun0"
    CHECK_RESULT $? 1
    targetcli restoreconfig | grep "Configuration restored from /etc/target/saveconfig.json"
    CHECK_RESULT $?
    targetcli ls | grep -E "file1|$iscsiName|lun0"
    CHECK_RESULT $?
    targetcli iscsi/ delete $iscsiName | grep "Deleted Target $iscsiName"
    CHECK_RESULT $?
    targetcli backstores/fileio delete file1 | grep "Deleted storage object file1"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -v ".sh")
    targetcli backstores/fileio delete file1
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
