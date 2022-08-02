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
        log_file target_log9
        spawn targetcli
        expect "/>" {send "iscsi/ create\r"}
        expect "/>" {send "backstores/fileio create disk1 /disks 140M\r"}
        expect "/>" {send "help set\r"}
        expect "/>" {send "get global auto_save_on_exit\r"}
        expect "/>" {send "set global auto_save_on_exit=false\r"}
        expect "/>" {send "help saveconfig\r"}
        expect "/>" {send "saveconfig ./saveconfig.json\r"}
        expect "/>" {send "set global auto_save_on_exit=true\r"}
        expect "/>" {send "get global auto_save_on_exit\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    grep -E "Created fileio disk1 with size|Deleted storage object disk1|set \[group\] \[parameter=value...\]|auto_save_on_exit=true|Parameter auto_save_on_exit is now 'false'|auto_save_on_exit=false|Parameter auto_save_on_exit is now 'true'" target_log9
    CHECK_RESULT $?
    grep -E "saveconfig \[savefile\]|Saves the current configuration to a file so that it can be restored|Configuration saved to ./saveconfig.json" target_log9
    CHECK_RESULT $?
    grep -E "disk1|iqn.2003-01" ./saveconfig.json
    CHECK_RESULT $?
    iscsiName=$(targetcli ls | grep iqn.2003-01 | awk -F " " '{print $3}')
    expect <<EOF
        spawn targetcli
        expect "/>" {send "iscsi/ delete $iscsiName\r"}
        expect "/>" {send "backstores/fileio/ delete disk1\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    expect <<EOF
        log_file target_log10
        spawn targetcli
        expect "/>" {send "iscsi/ create\r"}
        expect "/>" {send "backstores/fileio create disk1 /disks 140M\r"}
        expect "/>" {send "saveconfig ./saveconfig.json\r"}
        expect "/>" {send "help clearconfig\r"}
        expect "/>" {send "clearconfig confirm=True\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    grep -E "Configuration saved to ./saveconfig.json|clearconfig \[confirm\]|Removes entire configuration of backstores and targets|All configuration cleared" target_log10
    CHECK_RESULT $?
    targetcli ls | grep -E "iqn.2003-01|disk1"
    CHECK_RESULT $? 1
    expect <<EOF
        log_file target_log11
        spawn targetcli
        expect "/>" {send "help restoreconfig\r"}
        expect "/>" {send "restoreconfig ./saveconfig.json\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    grep -E "restoreconfig \[savefile\] \[clear_existing\]|Restores configuration from a file|Configuration restored from ./saveconfig.json" target_log11
    CHECK_RESULT $?
    targetcli ls | grep -E "iqn.2003-01|disk1"
    CHECK_RESULT $?
    iscsiName=$(targetcli ls | grep iqn.2003-01 | awk -F " " '{print $3}')
    expect <<EOF
        spawn targetcli
        expect "/>" {send "iscsi/ delete $iscsiName\r"}
        expect "/>" {send "backstores/fileio/ delete disk1\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    expect <<EOF
        log_file target_log12
        spawn targetcli
        expect "/>" {send "help sessions\r"}
        expect "/>" {send "sessions\r"}
        expect "/>" {send "sessions action=list\r"}
        expect "/>" {send "exit\r"}
        expect eof
EOF
    grep -E "sessions \[action\] \[sid\]|Displays a detailed list of all open sessions|\(no open sessions\)" target_log12
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
