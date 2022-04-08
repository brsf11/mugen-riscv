#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

###################################
#@Author    :   qinhaiqi
#@Contact   :   2683064908@qq.com
#@Date      :   2022/2/16
#@License   :   Mulan PSL v2
#@Desc      :   Test "other cobbler" command
###################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    echo 20 > test.json
    DNF_INSTALL "cobbler httpd"
    systemctl start httpd
    systemctl start cobblerd
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
     LOG_INFO "Start to run testcase."
     cobbler aclsetup --adduser=root --addgroup=root --removeuser=root --removegroup=root | grep "aclsetup"
     CHECK_RESULT $? 0 0 "Failed option: aclsetup"
     cobbler buildiso | grep "buildiso"
     CHECK_RESULT $? 0 0 "Failed option: buildiso"
     test -f generated.iso
     CHECK_RESULT $? 0 0 "Failed option: buildiso"
     cobbler import --name=openEuler --arch=x86_64 | grep "import"
     CHECK_RESULT $? 0 0 "Failed option: import"
     cobbler list | grep "distros" 
     CHECK_RESULT $? 0 0 "Failed option: list"
     cobbler report | grep "distros"
     CHECK_RESULT $? 0 0 "Failed option: report"
     cobbler reposync --only=only | grep "reposync"
     CHECK_RESULT $? 0 0 "Failed option: reposync"
     cobbler sync --verbose | grep "sync"
     CHECK_RESULT $? 0 0 "Failed option: sync"
     cobbler validate-autoinstalls | grep "validate_autoinstall"
     CHECK_RESULT $? 0 0 "Failed option: validate-autoinstalls"
     cobbler version | grep "Cobbler [[:digit:]]*"
     CHECK_RESULT $? 0 0 "Failed option: version"
     cobbler signature update | grep "signatures"
     CHECK_RESULT $? 0 0 "Failed option: signature update"
     cobbler signature reload --filename=test.json | grep "Signatures were successfully loaded" 
     CHECK_RESULT $? 0 0 "Failed option: signature reload"
     cobbler signature report | grep "signatures"
     CHECK_RESULT $? 0 0 "Failed option: signature report"
     cobbler get-loaders --force |grep "get_loaders"
     CHECK_RESULT $? 0 0 "Failed option: get-loaders"
     cobbler hardlink | grep "hardlink"
     CHECK_RESULT $? 0 0 "Failed option: hardlink"    
     cobbler replicate --master=${NODE1_IPV4} | grep "replicate"
     CHECK_RESULT $? 0 0 "Failed option: replicate"
     LOG_INFO "End to run testcase."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test.json generated.iso
    systemctl stop httpd
    systemctl stop cobblerd
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
